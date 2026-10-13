--Actividad 12: Subconsultas correlacionadas y cuentas sin movimientos

--1.-Moviminto que superan el promedio de su propia cuenta
SELECT 
    t.transaction_id,
    t.account_id,
    t.amount,
    t.tx_type,
    (
        SELECT ROUND(AVG(sub.amount), 2)
        FROM core.transactions sub
        WHERE sub.account_id = t.account_id
    ) AS promedio_propio_cuenta
FROM 
    core.transactions t
WHERE 
    t.amount > (
        SELECT AVG(sub.amount)
        FROM core.transactions sub
        WHERE sub.account_id = t.account_id
    )
ORDER BY 
    t.account_id ASC, 
    t.amount DESC;

--2.-Cuentas sin mantenimiento
SELECT 
    account_id,
    COUNT(transaction_id) AS total_movimientos,
    ROUND(AVG(amount), 2) AS promedio_agrupado_control
FROM 
    core.transactions
GROUP BY 
    account_id
ORDER BY 
    account_id ASC;

--3.-Cuentas sin eventos mediante NOT EXISTS (Exclusión Segura)
SELECT 
    a.account_number,
    a.is_active,
    a.account_type
FROM 
    core.accounts a
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM core.transactions t 
        WHERE t.account_id = a.account_id
    )
ORDER BY 
    a.account_number ASC;