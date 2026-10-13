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

Lo que aprendi: Ajusté la agrupación por moneda y los cálculos generales para que el 
reporte final coincidiera con el enfoque del profesor.  


Fix:# Day 13 Answer Key — Extensión de CTE y pipeline de métricas por cuenta

## Expected Result
La semilla inicial produce una fila USD, cuatro cuentas activas, volumen bruto 800 y promedio de 200 por cuenta.

## Reference Solution
```sql
WITH movement AS (
 SELECT account_id, SUM(amount) AS gross_volume
 FROM core.transactions GROUP BY account_id
), account_metrics AS (
 SELECT a.account_id, a.currency, COALESCE(m.gross_volume,0) AS gross_volume
 FROM core.accounts a LEFT JOIN movement m USING (account_id)
 WHERE a.is_active
), by_currency AS (
 SELECT currency, COUNT(*) AS account_count, SUM(gross_volume) AS gross_volume
 FROM account_metrics GROUP BY currency
)
SELECT currency, account_count, gross_volume,
       ROUND(gross_volume / account_count,2) AS average_per_account
FROM by_currency ORDER BY currency;

SELECT (SELECT COUNT(*) FROM core.accounts WHERE is_active) AS active_accounts,
       (SELECT COALESCE(SUM(amount),0) FROM core.transactions) AS direct_gross_volume,
       (SELECT COUNT(*) FROM core.transactions t JOIN core.accounts a USING (account_id)
        WHERE a.account_number='ACCT-3002') AS empty_account_events;