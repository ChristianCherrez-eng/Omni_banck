--Tarea 9: diagnóstico de combinaciones sin relación en OmniBank

--1.-Cuantifica la matriz sin relaciones.
SELECT 
    (SELECT COUNT(*) FROM core.customers) AS total_customers,
    (SELECT COUNT(*) FROM core.accounts) AS total_accounts,
    (SELECT COUNT(*) FROM core.transactions) AS total_transactions,
    (SELECT COUNT(*) FROM core.customers) * 
    (SELECT COUNT(*) FROM core.accounts) * 
    (SELECT COUNT(*) FROM core.transactions) AS producto_cartesiano_total;

--2.- Repara el reporte de movimientos.
SELECT 
    c.email,
    a.account_number,
    t.tx_type,
    t.amount,
    t.created_at
FROM 
    core.transactions t
INNER JOIN 
    core.accounts a ON t.account_id = a.account_id
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
WHERE 
    c.is_active = true 
    AND t.amount >= 100.00
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;

