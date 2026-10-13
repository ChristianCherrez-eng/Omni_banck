--Tarea 13: Extensión de CTE y pipeline de métricas por cuenta


WITH movimientos_agregados AS (
    -- Grano: 1 fila por cada cuenta que registró al menos un movimiento.
    SELECT 
        account_id,
        COUNT(transaction_id) AS numero_eventos,
        SUM(amount) AS volumen_bruto
    FROM 
        core.transactions
    GROUP BY 
        account_id
),
cuentas_activas_metricas AS (
    SELECT 
        a.account_id,
        a.account_number,
        a.currency,
        COALESCE(m.volumen_bruto, 0.00) AS volumen_bruto_registrado
    FROM 
        core.accounts a
    LEFT JOIN 
        movimientos_agregados m ON a.account_id = m.account_id
    WHERE 
        a.is_active = true
),
resumen_por_moneda AS (
    SELECT 
        currency AS moneda,
        COUNT(account_id) AS total_cuentas_activas,
        SUM(volumen_bruto_registrado) AS volumen_bruto_total,
        ROUND(AVG(volumen_bruto_registrado), 2) AS volumen_medio_por_cuenta
    FROM 
        cuentas_activas_metricas
    GROUP BY 
        currency
)
SELECT 
    moneda,
    total_cuentas_activas,
    volumen_bruto_total,
    volumen_medio_por_cuenta
FROM 
    resumen_por_moneda
ORDER BY 
    moneda ASC;

SELECT COUNT(*) AS control_total_cuentas_activas 
FROM core.accounts 
WHERE is_active = true;

SELECT SUM(amount) AS control_volumen_bruto_global 
FROM core.transactions;

SELECT 
    800.00 / 4 AS control_promedio_matematico;