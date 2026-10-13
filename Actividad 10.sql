--Actividad 10: tablero de saldos y actividad registrada de OmniBank

--1.-Tablero de productos: una fila por tipo de cuenta activo.
SELECT 
    account_type AS tipo_cuenta,
    COUNT(*) AS total_cuentas_activas,
    SUM(balance) AS saldo_total_almacenado,
    MIN(balance) AS saldo_minimo_almacenado,
    MAX(balance) AS saldo_maximo_almacenado,
    ROUND(AVG(balance), 2) AS saldo_promedio_almacenado
FROM 
    core.accounts
WHERE 
    is_active = true
GROUP BY 
    account_type
ORDER BY 
    saldo_total_almacenado DESC, 
    tipo_cuenta ASC;

--2.-Segmentación de titulares: una fila por cliente elegible.
SELECT 
    c.customer_id,
    c.email,
    COUNT(t.transaction_id) AS total_movimientos,
    COALESCE(SUM(t.amount), 0.00) AS volumen_bruto_registrado
FROM 
    core.customers c
LEFT JOIN 
    core.accounts a ON c.customer_id = a.customer_id
LEFT JOIN 
    core.transactions t ON a.account_id = t.account_id
GROUP BY 
    c.customer_id,
    c.email
HAVING 
    COUNT(t.transaction_id) >= 2 
    OR COALESCE(SUM(t.amount), 0.00) > 100.00
ORDER BY 
    volumen_bruto_registrado DESC, 
    c.email ASC;

--3.-Control independiente.
SELECT 
    account_id,
    COUNT(transaction_id) AS numero_movimientos,
    SUM(amount) AS volumen_total_movimientos
FROM 
    core.transactions
GROUP BY 
    account_id;

SELECT 
    SUM(balance) AS saldo_global_activo
FROM 
    core.accounts
WHERE 
    is_active = true;


Lo que aprendi:  Modifiqué las funciones de agregación para obtener los totales y 
resúmenes de la forma exacta en que los pedía la práctica. 


Fix: # Day 10 Answer Key — Tablero de saldos y actividad

## Expected Result

Las cuatro cuentas activas suman 19 950: CHECKING 4 950, SAVINGS 15 000 y CREDIT 0. El segmento de actividad contiene a Alice y Jane con volumen bruto 300, y a John con 200 y dos eventos. Los cuatro eventos suman 800. Ninguna de esas sumas de eventos representa el saldo de una cuenta.

## Reference Solution

```sql
-- Grano: account_type. balance procede solo de accounts.
SELECT account_type,
       COUNT(*) AS account_count,
       SUM(balance) AS stored_balance_total,
       MIN(balance) AS smallest_stored_balance,
       MAX(balance) AS largest_stored_balance,
       ROUND(AVG(balance), 2) AS average_stored_balance
FROM core.accounts
WHERE is_active
GROUP BY account_type
ORDER BY stored_balance_total DESC, account_type;

-- Grano: cliente. transaction_id cuenta eventos reales, no filas externas.
SELECT c.customer_id, c.first_name, c.last_name, c.email,
       COUNT(t.transaction_id) AS recorded_event_count,
       COALESCE(SUM(t.amount), 0) AS recorded_gross_volume
FROM core.customers c
LEFT JOIN core.accounts a ON a.customer_id = c.customer_id
LEFT JOIN core.transactions t ON t.account_id = a.account_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING COUNT(t.transaction_id) >= 2 OR COALESCE(SUM(t.amount), 0) > 100
ORDER BY recorded_gross_volume DESC, c.email;

-- Controles independientes: cada medida se obtiene en su tabla de origen.
SELECT COUNT(*) AS active_accounts,
       SUM(balance) AS stored_balance_total
FROM core.accounts 
WHERE is_active;

SELECT COUNT(*) AS recorded_events,
       SUM(amount) AS recorded_gross_volume
FROM core.transactions;
```

La cuenta `CREDIT` de Alice tiene saldo almacenado cero y un depósito histórico de 300. La coexistencia no obliga a corregir ningún dato: la semilla solo registra parte de la historia. La condición de `HAVING` se evalúa después de agrupar; moverla a `WHERE` no compila como condición agregada.

## Common Valid Variations

Puede preagregarse `transactions` por `account_id` antes de unirlo con `accounts`, siempre que el informe final conserve una fila por titular y no cuente una fila externa como evento. También se acepta `FILTER` con la misma semántica.

## Common Mistakes

`SUM(balance)` sobre una unión con eventos duplica el saldo de `ACCT-1001`. `COUNT(*)` en una unión externa atribuye un evento a Humberto. `COALESCE(balance, 0)` es redundante para esta columna `NOT NULL` y no demuestra el efecto de nulos sobre `AVG`.

## Grading Rubric

* **30%:** Tablero desde cuentas activas, cinco funciones agregadas y tres tipos presentes.
* **25%:** Informe por cliente con `LEFT JOIN`, `COUNT(transaction_id)` y `HAVING` correcto.
* **25%:** Controles independientes que confirman 19 950 y 800, con nombres de métricas precisos.
* **20%:** Interpretación de saldo frente a volumen y explicación del grano antes y después de las uniones.