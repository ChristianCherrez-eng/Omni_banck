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


Lo que aprendi: Ajusté el manejo de espacios vacíos en los promedios siguiendo la 
aclaración que dio el profesor sobre los datos nulos.  


Fix: # Day 10 Answer Key — Promedios y actividad de crédito

## Expected Result

La muestra arroja 3333.33 si se ignora NULL y 2500.00 si se convierte a cero. ACCT-3001 aparece con balance 0 y volumen bruto 300.

## Reference Solution

```sql
WITH sample(x) AS (
    VALUES (NULL::numeric), (10000::numeric), (0::numeric), (0::numeric)
)
SELECT ROUND(AVG(x), 2) AS ignores_null,
       ROUND(AVG(COALESCE(x, 0)), 2) AS treats_null_as_zero
FROM sample;

SELECT c.email, a.account_number, a.balance AS stored_balance,
       COUNT(t.transaction_id) AS movement_count,
       COALESCE(SUM(t.amount), 0) AS recorded_gross_volume
FROM core.customers c 
JOIN core.accounts a USING (customer_id)
LEFT JOIN core.transactions t USING (account_id)
WHERE a.account_type = 'CREDIT' AND a.is_active
GROUP BY c.customer_id, c.email, a.account_id, a.account_number, a.balance
HAVING COALESCE(SUM(t.amount), 0) >= 300 OR COUNT(t.transaction_id) = 0
ORDER BY recorded_gross_volume DESC;
```

**Lectura de la solución:** La revisión crediticia necesita un ejemplo en el que `AVG` ignore un `NULL` de forma visible, además de una fila de prueba para `CREDIT`. El objetivo es explicar el denominador real de `AVG` y enlazarlo con el reporte agregado construido en la actividad, no inventar un límite crediticio que el esquema no guarda.

## Common Valid Variations

Puede usarse `FILTER` para separar grupos o una CTE de movimientos por cuenta, siempre que el saldo no se multiplique, el promedio conserve su denominador declarado y el segmento incluya cuentas sin eventos.

## Common Mistakes

Unir `accounts` con `transactions` antes de `SUM(balance)` duplica saldos de cuentas con varios movimientos; `AVG` sobre `NULL` tampoco equivale a `AVG` sobre cero.

## Grading Rubric

* **35%:** Construye una muestra con 10000, 0, 0 y `NULL` y explica por qué `AVG` usa denominadores 3 y 4 según se aplique `COALESCE`.

* **30%:** Selecciona cuentas `CREDIT` activas y conserva con `HAVING` las que no tengan eventos o registren volumen bruto de al menos 300; muestra saldo, recuento y volumen sin multiplicar saldos.

* **20%:** Comprueba el resultado con datos reproducibles: La muestra arroja 3333.33 si se ignora `NULL` y 2500.00 si se convierte a cero. ACCT-3001 aparece con balance 0 y volumen bruto 300.

* **15%:** Reconoce y evita este error: Unir `accounts` con `transactions` antes de `SUM(balance)` duplica saldos de cuentas con varios movimientos; `AVG` sobre `NULL` tampoco equivale a `AVG` sobre cero.