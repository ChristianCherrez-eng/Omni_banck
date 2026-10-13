--Actividad 13: CTE y pipeline de métricas por cuenta

--1.-Aregado por movimineto
WITH movimientos_agregados AS (
        SELECT 
        account_id,
        COUNT(transaction_id) AS numero_eventos,
        SUM(amount) AS volumen_bruto
    FROM 
        core.transactions
    GROUP BY 
        account_id),
cuentas_activas_metricas AS (
        SELECT 
        a.account_id,
        a.account_number,
        a.currency,
        a.customer_id,
        COALESCE(m.numero_eventos, 0) AS numero_eventos,
        COALESCE(m.volumen_bruto, 0.00) AS volumen_bruto_registrado
    FROM 
        core.accounts a
    LEFT JOIN 
        movimientos_agregados m ON a.account_id = m.account_id
    WHERE 
        a.is_active = true
)
SELECT 
    cam.account_number,
    c.first_name || ' ' || c.last_name AS titular,
    cam.currency AS moneda,
    cam.numero_eventos,
    cam.volumen_bruto_registrado,
    CASE 
        WHEN cam.volumen_bruto_registrado >= 300.00 THEN 'ALTO VOLUMEN'
        WHEN cam.volumen_bruto_registrado > 0.00 THEN 'MODERADO'
        ELSE 'SIN ACTIVIDAD'
    END AS banda_actividad
FROM 
    cuentas_activas_metricas cam
INNER JOIN 
    core.customers c ON cam.customer_id = c.customer_id
ORDER BY 
    cam.account_number ASC;
SELECT COUNT(*) AS total_cuentas_activas 
FROM core.accounts 
WHERE is_active = true;

SELECT SUM(amount) AS volumen_bruto_global 
FROM core.transactions;