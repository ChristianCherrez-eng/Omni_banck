--Actividad 9: reportes relacionales para operaciones de OmniBank

--1.-Punto de control de la semilla.
SELECT 
    (SELECT COUNT(*) FROM core.customers) AS total_customers,
    (SELECT COUNT(*) FROM core.accounts) AS total_accounts,
    (SELECT COUNT(*) FROM core.transactions) AS total_transactions;

--2.-Recorrido de cada movimiento.
SELECT 
    t.transaction_id,
    c.first_name,
    c.last_name,
    a.account_number,
    t.tx_type,
    t.amount
FROM 
    core.transactions t
INNER JOIN 
    core.accounts a ON t.account_id = a.account_id
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;

--3.-Cuentas sin movimientos.
SELECT 
    a.account_number,
    a.is_active,
    CASE 
        WHEN a.is_active = false THEN 'CUENTA DESACTIVADA SIN ACTIVIDAD'
        ELSE 'CUENTA ACTIVA - SIN MOVIMIENTOS REGISTRADOS'
    END AS etiqueta_presentacion
FROM 
    core.accounts a
LEFT JOIN 
    core.transactions t ON a.account_id = t.account_id
WHERE 
    t.transaction_id IS NULL;

--4.-Titulares con cuenta elegible, si existe.
SELECT 
    cust.email,
    acc.account_number,
    acc.balance
FROM 
    core.customers cust
LEFT JOIN 
    core.accounts acc ON cust.customer_id = acc.customer_id AND acc.balance > 0.00;