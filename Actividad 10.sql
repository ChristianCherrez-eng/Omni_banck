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