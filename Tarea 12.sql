--Tarea 12: Exclusión segura con NOT EXISTS y NULL

--1.-Cuentas activas sin ningun movimiento
SELECT 
    a.account_number,
    a.is_active,
    a.account_type
FROM 
    core.accounts a
WHERE 
    a.is_active = true
    AND NOT EXISTS (
        SELECT 1 
        FROM core.transactions t 
        WHERE t.account_id = a.account_id
    )
ORDER BY 
    a.account_number ASC;

--2.-Cuentas sin eventos de tipo DEPOSIT
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
          AND t.tx_type = 'DEPOSIT'
    )
ORDER BY 
    a.account_number ASC;

--3.-Muestra aislada demotracion de fallo de NOT IN con NULL
WITH lista_valores AS (
    SELECT 10 AS val UNION ALL
    SELECT 20 UNION ALL
    SELECT NULL::INTEGER AS val
)
SELECT 
        (SELECT COUNT(*) FROM (
        SELECT 5 WHERE 5 NOT IN (SELECT val FROM lista_valores)
    ) AS test_not_in) AS resultado_filas_not_in,\(SELECT COUNT(*) FROM (
        SELECT 5 WHERE NOT EXISTS (SELECT 1 FROM lista_valores WHERE val = 5)
    ) AS test_not_exists) AS resultado_filas_not_exists;