--Tarea 14: Extensión de Self JOIN, matriz de productos y anti JOIN

SELECT 
    a.account_number,
    a.account_type,
    a.is_active,
    c.first_name || ' ' || c.last_name AS titular
FROM 
    core.accounts a
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
WHERE 
    a.is_active = true
    AND NOT EXISTS (
        SELECT 1 
        FROM core.transactions t 
        WHERE t.account_id = a.account_id 
          AND t.tx_type = 'DEPOSIT')
ORDER BY 
    a.account_number ASC;

SELECT COUNT(*) AS total_cuentas_activas 
FROM core.accounts 
WHERE is_active = true;

SELECT 
    a.account_number,
    COUNT(t.transaction_id) AS total_movimientos
FROM 
    core.accounts a
LEFT JOIN 
    core.transactions t ON a.account_id = t.account_id
WHERE 
    a.is_active = true
GROUP BY 
    a.account_number
ORDER BY 
    a.account_number ASC;

