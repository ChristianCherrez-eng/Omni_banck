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


Lo que aprendi:Cambié el comando de búsqueda por la opción más segura 
recomendada en la solución para evitar fallos con nulos.  


Fix: # Day 12 Answer Key — Exclusión segura

## Expected Result

Solo ACCT-3002 está activa y sin eventos. Cuatro cuentas no registran DEPOSIT: ACCT-1001, ACCT-1002, ACCT-2001 y ACCT-3002.

## Reference Solution

```
SELECT a.account_number, a.account_type, a.balance
FROM core.accounts a
WHERE a.is_active
  AND NOT EXISTS (
    SELECT 1 FROM core.transactions t WHERE t.account_id = a.account_id
  )
ORDER BY a.account_number;

SELECT a.account_number, a.is_active
FROM core.accounts a
WHERE NOT EXISTS (
  SELECT 1 FROM core.transactions t
  WHERE t.account_id = a.account_id AND t.tx_type = 'DEPOSIT'
)
ORDER BY a.account_number;

WITH valores(x) AS (VALUES (1), (NULL::integer))
SELECT 2 NOT IN (SELECT x FROM valores) AS not_in_with_null,
       NOT EXISTS (SELECT 1 FROM valores WHERE x = 2) AS not_exists_result;

```

El comparador de `NOT IN` encuentra un `NULL` y no puede demostrar que 2 sea distinto de todos los valores: el resultado es `UNKNOWN`. `NOT EXISTS` solo pregunta si existe una fila que satisfaga `x = 2` y devuelve `TRUE` cuando no la hay.

**Lectura de la solución:** La misma revisión necesita separar cuentas activas sin eventos de cuentas que nunca han recibido un depósito. El segundo conjunto no equivale al primero: una cuenta puede tener transferencias o retiros y seguir sin `DEPOSIT`. La tarea consolida el uso de `NOT EXISTS` antes de introducir CTE en el día siguiente.

## Common Valid Variations

Una CTE con promedio por `account_id` puede sustituir la subconsulta correlacionada si conserva la misma comparación y el tratamiento de cuentas sin eventos.

## Common Mistakes

Olvidar la correlación por `account_id` convierte una excepción local en una comparación global; `NOT IN` con `NULL` puede eliminar resultados esperados.

## Grading Rubric

* **35%:** Extiende la consulta de ausencia de la actividad para devolver solo cuentas activas sin ningún movimiento. Mantén el filtro administrativo fuera de la subconsulta de existencia.

* **30%:** Construye un segundo `NOT EXISTS` que busque ausencia de `DEPOSIT` para todas las cuentas. No confíes en `NOT IN` si la subconsulta puede devolver `NULL`; muestra con una pequeña consulta de valores por qué ese caso cambia la lógica.

* **20%:** Comprueba el resultado con datos reproducibles: Solo ACCT-3002 está activa y sin eventos. Cuatro cuentas no registran DEPOSIT: ACCT-1001, ACCT-1002, ACCT-2001 y ACCT-3002.

* **15%:** Reconoce y evita este error: Olvidar la correlación por `account_id` convierte una excepción local en una comparación global; `NOT IN` con `NULL` puede eliminar resultados esperados.