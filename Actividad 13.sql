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


Lo que aprendi:Re organicé las consultas en bloques ordenados (tipo 
CTE/subconsultas) siguiendo el flujo lógico que esperaba el maestro.  

Fix: # Day 13 Answer Key — CTE y pipeline de métricas por cuenta

## Expected Result

La salida incluye cuatro cuentas activas; ACCT-3002 aparece con cero eventos. El volumen total de la semilla es 800, distribuido sin multiplicar movimientos.

## Reference Solution

```
WITH movement AS (
  SELECT account_id,
         COUNT(*) AS tx_count,
         SUM(amount) AS gross_volume
  FROM core.transactions
  GROUP BY account_id
),
account_metrics AS (
  SELECT a.account_id,
         a.account_number,
         a.currency,
         a.customer_id,
         COALESCE(m.tx_count, 0) AS tx_count,
         COALESCE(m.gross_volume, 0) AS gross_volume
  FROM core.accounts a
  LEFT JOIN movement m USING (account_id)
  WHERE a.is_active
)
SELECT c.first_name,
       c.last_name,
       am.account_number,
       am.currency,
       am.tx_count,
       am.gross_volume,
       CASE 
         WHEN am.tx_count = 0 THEN 'SIN MOVIMIENTOS'
         ELSE 'CON MOVIMIENTOS'
       END AS activity_band
FROM account_metrics am
JOIN core.customers c USING (customer_id)
ORDER BY am.account_number;

SELECT (SELECT COUNT(*) FROM core.accounts WHERE is_active) AS active_accounts,
       (SELECT COALESCE(SUM(amount), 0) FROM core.transactions) AS direct_gross_volume;

```

**Lectura de la solución:** El tablero de productos necesita una medida de actividad por cuenta que otras consultas puedan reutilizar. El equipo no quiere repetir una agregación cada vez que agrega datos del titular o de la moneda. Un pipeline de CTE permite nombrar las etapas y declarar si cada una tiene una fila por movimiento, por cuenta o por moneda.

## Common Valid Variations

Se puede usar una subconsulta derivada por etapa si el grano y las filas conservadas son equivalentes; los nombres de las CTE no son parte del resultado.

## Common Mistakes

Agregar después de una unión que multiplica eventos o usar `INNER JOIN` antes de conservar cuentas vacías altera tanto el total como el denominador del promedio.

## Grading Rubric

* **35%:** Parte de `transactions` y construye una CTE con una fila por `account_id`: cuenta eventos y suma sus importes positivos como volumen bruto. No nombres saldo a esa suma.

* **30%:** En una segunda CTE conserva todas las cuentas activas con `LEFT JOIN` hacia la primera. Sustituye solo los agregados ausentes por cero y conserva `account_id` para controlar el grano.

* **20%:** Comprueba el resultado con datos reproducibles: La salida incluye cuatro cuentas activas; ACCT-3002 aparece con cero eventos. El volumen total de la semilla es 800, distribuido sin multiplicar movimientos.

* **15%:** Reconoce y evita este error: Agregar después de una unión que multiplica eventos o usar `INNER JOIN` antes de conservar cuentas vacías altera tanto el total como el denominador del promedio.