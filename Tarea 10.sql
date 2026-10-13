--Tarea 10: Promedios con NULL y reporte de actividad de crédito

--1.-Prueba del AVG con NULL
WITH muestra AS (
    SELECT 10000.00 AS v UNION ALL
    SELECT 0.00 UNION ALL
    SELECT 0.00 UNION ALL
    SELECT NULL::NUMERIC AS v
)
SELECT 
    ROUND(AVG(v), 2) AS promedio_sin_null,
    COUNT(v) AS denominador_sin_null,
    ROUND(AVG(COALESCE(v, 0.00)), 2) AS promedio_con_coalesce,
    COUNT(*) AS denominador_con_coalesce
FROM 
    muestra;

--2.-Reporte de cuentas CREDIT activas
SELECT 
    a.account_number,
    a.balance AS saldo_almacenado,
    COUNT(t.transaction_id) AS numero_movimientos,
    COALESCE(SUM(t.amount), 0.00) AS volumen_bruto_registrado
FROM 
    core.accounts a
LEFT JOIN 
    core.transactions t ON a.account_id = t.account_id
WHERE 
    a.account_type = 'CREDIT'
    AND a.is_active = true
GROUP BY 
    a.account_id,
    a.account_number,
    a.balance
HAVING 
    COUNT(t.transaction_id) = 0 
    OR COALESCE(SUM(t.amount), 0.00) >= 300.00
ORDER BY 
    a.account_number ASC;