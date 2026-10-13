# Checkpoint de Continuidad (Día 08 - OmniBank)

```sql
-- Checkpoint de continuidad después del día 08 para la cohorte publicada.
-- Ejecutar UNA vez en una base nueva y vacía. No ejecutar sobre entregas existentes.
-- Los bloques provienen del DDL de los días 05–06 y la carga idempotente del día 07.
DO $$
BEGIN
  IF to_regnamespace('core') IS NOT NULL THEN
    RAISE EXCEPTION 'El checkpoint requiere una base nueva sin el esquema core';
  END IF;
END $$;

-- Fuente: repository_packages/instructor-key/02_ddl/01_tables_core.sql
-- Contrato OmniBank de los días 04 y 05. Ejecutar una vez en una base vacía.
CREATE SCHEMA IF NOT EXISTS core;
CREATE TYPE core.tipo_moneda AS ENUM ('USD', 'EUR', 'MXN', 'GBP');
CREATE TYPE core.tipo_cuenta AS ENUM ('CHECKING', 'SAVINGS', 'CREDIT');
CREATE TYPE core.tipo_transaccion AS ENUM ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER');

CREATE TABLE core.customers (
    customer_id UUID DEFAULT gen_random_uuid(),
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    tax_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email),
    CONSTRAINT uq_customers_tax_id UNIQUE (tax_id)
);

CREATE TABLE core.accounts (
    account_id UUID DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    account_number VARCHAR(30) NOT NULL,
    currency core.tipo_moneda NOT NULL DEFAULT 'USD',
    account_type core.tipo_cuenta NOT NULL DEFAULT 'CHECKING',
    balance NUMERIC(15,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT pk_accounts PRIMARY KEY (account_id),
    CONSTRAINT uq_accounts_number UNIQUE (account_number),
    CONSTRAINT chk_accounts_balance_no_negativo CHECK (balance >= 0),
    CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id)
        REFERENCES core.customers(customer_id) ON DELETE RESTRICT
);

CREATE TABLE core.loans (
    loan_id UUID DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    loan_number VARCHAR(30) NOT NULL,
    principal_amount NUMERIC(15,2) NOT NULL,
    interest_rate NUMERIC(6,4) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_loans PRIMARY KEY (loan_id),
    CONSTRAINT uq_loans_number UNIQUE (loan_number),
    CONSTRAINT chk_loans_principal CHECK (principal_amount > 0),
    CONSTRAINT chk_loans_rate CHECK (interest_rate >= 0),
    CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id)
        REFERENCES core.customers(customer_id) ON DELETE RESTRICT
);

CREATE TABLE core.transactions (
    transaction_id UUID DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    tx_type core.tipo_transaccion NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    tx_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(250),
    CONSTRAINT pk_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT chk_transactions_amount CHECK (amount > 0),
    CONSTRAINT fk_transactions_account FOREIGN KEY (account_id)
        REFERENCES core.accounts(account_id) ON DELETE RESTRICT
);

-- Fuente: repository_packages/instructor-key/02_ddl/01b_migration_day06.sql
-- Día 06: evolución incremental del contrato; ninguna tabla core se reemplaza.
BEGIN;
CREATE TYPE core.loan_status_enum AS ENUM ('ACTIVE', 'PAID', 'DEFAULTED', 'CANCELLED');
ALTER TABLE core.customers ADD COLUMN credit_score INTEGER;
ALTER TABLE core.customers ADD CONSTRAINT chk_customers_credit_score_range
    CHECK (credit_score BETWEEN 300 AND 850);
ALTER TABLE core.accounts ADD COLUMN iban VARCHAR(34);
ALTER TABLE core.accounts ADD CONSTRAINT uq_accounts_iban UNIQUE (iban);
ALTER TABLE core.loans ALTER COLUMN status DROP DEFAULT;
ALTER TABLE core.loans ALTER COLUMN status TYPE core.loan_status_enum
    USING status::core.loan_status_enum;
ALTER TABLE core.loans ALTER COLUMN status SET DEFAULT 'ACTIVE'::core.loan_status_enum;
ALTER TABLE core.transactions ADD CONSTRAINT chk_transactions_description_min_length
    CHECK (description IS NULL OR length(trim(description)) >= 5) NOT VALID;
ALTER TABLE core.transactions VALIDATE CONSTRAINT chk_transactions_description_min_length;
COMMIT;

-- Fuente: repository_packages/instructor-key/02_ddl/03_initial_data.sql
-- Día 07. Una o dos ejecuciones producen el mismo estado de las cuatro tablas.
-- Los movimientos de ejemplo son eventos históricos; balance es una instantánea.
-- TRANSFER registra solo la cuenta asociada: no permite inferir destinatario.
BEGIN;
INSERT INTO core.customers (customer_id, first_name, last_name, email, phone, tax_id, credit_score)
VALUES
 ('11111111-1111-1111-1111-111111111111','John','Doe','john.doe@email.com','555-0100','TAX-100',720),
 ('22222222-2222-2222-2222-222222222222','Jane','Smith','jane.smith@email.com','555-0200','TAX-200',780),
 ('33333333-3333-3333-3333-333333333333','Alice','Johnson','alice.j@email.com','555-0300','TAX-300',650)
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO core.accounts (account_id, customer_id, account_number, account_type, balance, is_active)
VALUES
 ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','11111111-1111-1111-1111-111111111111','ACCT-1001','CHECKING',5000,true),
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','22222222-2222-2222-2222-222222222222','ACCT-2001','SAVINGS',15000,true),
 ('cccccccc-cccc-cccc-cccc-cccccccccccc','33333333-3333-3333-3333-333333333333','ACCT-3001','CREDIT',0,true),
 ('dddddddd-dddd-dddd-dddd-dddddddddddd','33333333-3333-3333-3333-333333333333','ACCT-3002','SAVINGS',0,true),
 ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee','11111111-1111-1111-1111-111111111111','ACCT-1002','SAVINGS',0,false)
ON CONFLICT (account_id) DO NOTHING;

-- Identificadores estables permiten ON CONFLICT también para el ledger.
INSERT INTO core.transactions (transaction_id, account_id, tx_type, amount, tx_timestamp, description)
VALUES
 ('10000000-0000-0000-0000-000000000001','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','TRANSFER',150,'2026-09-01 10:00+00','Instrucción saliente registrada para John'),
 ('10000000-0000-0000-0000-000000000002','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','TRANSFER',300,'2026-09-02 10:00+00','Instrucción saliente registrada para Jane'),
 ('10000000-0000-0000-0000-000000000004','cccccccc-cccc-cccc-cccc-cccccccccccc','DEPOSIT',300,'2026-09-04 10:00+00','Abono histórico de Alice')
ON CONFLICT (transaction_id) DO NOTHING;

-- RETURNING enlaza el cargo con el evento nuevo; un reintento no debita otra vez.
WITH fee AS (
 INSERT INTO core.transactions (transaction_id, account_id, tx_type, amount, tx_timestamp, description)
 VALUES ('10000000-0000-0000-0000-000000000003','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
         'WITHDRAWAL',50,'2026-09-03 10:00+00',NULL)
 ON CONFLICT (transaction_id) DO NOTHING
 RETURNING account_id, amount
)
UPDATE core.accounts
SET balance = core.accounts.balance - fee.amount, updated_at = CURRENT_TIMESTAMP
FROM fee
WHERE core.accounts.account_id = fee.account_id
  AND core.accounts.account_number = 'ACCT-1001'
RETURNING core.accounts.account_number, core.accounts.balance;
COMMIT;

-- Extensión de la tarea del día 07: un cuarto cliente para el inicio del día 09.
INSERT INTO core.customers(first_name,last_name,email,phone,tax_id)
VALUES('Humberto','López','hlopez@email.com','+52-55-4433-2211','TAX-990011')
ON CONFLICT(email) DO UPDATE SET
 first_name=EXCLUDED.first_name,
 last_name=EXCLUDED.last_name,
 phone=EXCLUDED.phone
RETURNING customer_id,email,phone;

DO $$
BEGIN
  IF (SELECT COUNT(*) FROM core.customers) <> 4
     OR (SELECT COUNT(*) FROM core.accounts) <> 5
     OR (SELECT COUNT(*) FROM core.transactions) <> 4
     OR (SELECT balance FROM core.accounts WHERE account_number='ACCT-1001') <> 4950 THEN
    RAISE EXCEPTION 'El checkpoint no produjo el estado esperado';
  END IF;
END $$;
```