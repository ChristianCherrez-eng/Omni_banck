--Tarea 9: diagnóstico de combinaciones sin relación en OmniBank

--1.-Cuantifica la matriz sin relaciones.
SELECT 
    (SELECT COUNT(*) FROM core.customers) AS total_customers,
    (SELECT COUNT(*) FROM core.accounts) AS total_accounts,
    (SELECT COUNT(*) FROM core.transactions) AS total_transactions,
    (SELECT COUNT(*) FROM core.customers) * 
    (SELECT COUNT(*) FROM core.accounts) * 
    (SELECT COUNT(*) FROM core.transactions) AS producto_cartesiano_total;

--2.- Repara el reporte de movimientos.
SELECT 
    c.email,
    a.account_number,
    t.tx_type,
    t.amount,
    t.created_at
FROM 
    core.transactions t
INNER JOIN 
    core.accounts a ON t.account_id = a.account_id
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
WHERE 
    c.is_active = true 
    AND t.amount >= 100.00
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;


Lo que aprendi:  Corregí el traslape de tablas aplicando las uniones correctas que el 
profesor esperaba ver en la consulta.


Fix: # Day 09 Answer Key — Producto cartesiano y JOIN

## Expected Result
Los recuentos de la semilla son 4, 5 y 4: el producto es 80. El reporte con claves muestra tres eventos de al menos 100, no 80 operaciones.

## Reference Solution
```sql
SELECT (SELECT COUNT(*) FROM core.customers) AS customers,
       (SELECT COUNT(*) FROM core.accounts) AS accounts,
       (SELECT COUNT(*) FROM core.transactions) AS transactions;

SELECT COUNT(*) AS combinations
FROM core.customers CROSS JOIN core.accounts CROSS JOIN core.transactions;

SELECT c.email, a.account_number, t.tx_type, t.amount, t.tx_timestamp
FROM core.transactions t
JOIN core.accounts a ON a.account_id = t.account_id
JOIN core.customers c ON c.customer_id = a.customer_id
WHERE c.is_active AND t.amount >= 100
ORDER BY t.tx_timestamp, t.transaction_id;
```

El `CROSS JOIN` enumera todas las combinaciones posibles de las tres relaciones. La unión con claves preserva la pertenencia de cada movimiento a una cuenta y de esta a un cliente. El número de combinaciones por sí solo no determina el plan físico, la memoria usada ni el tiempo de respuesta.

**Lectura de la solución:** Una consulta exploratoria sin condiciones de unión puede producir muchas combinaciones que parecen operaciones bancarias pero que no corresponden a ninguna relación real. El área de revisión quiere cuantificar ese error lógico antes de incorporar el reporte al repositorio. La tarea extiende los `JOIN` de la actividad y deja un archivo reutilizable para los días de agregaciones.

## Common Valid Variations
Se aceptan `USING (account_id)` en la primera unión y una CTE que prefiltre los movimientos, siempre que el recorrido conserve las claves reales y el orden final desempate por `transaction_id`.

## Common Mistakes
Omitir cualquiera de las dos condiciones de unión multiplica filas y atribuye movimientos a titulares ajenos. El filtro `amount >= 100` se aplica después de reconstruir la relación; ordenar solo por importe no cumple la secuencia temporal solicitada.

## Grading Rubric
- **35%:** Cuenta las filas de `customers`, `accounts` y `transactions` y calcula su producto. Usa `CROSS JOIN` únicamente para obtener `COUNT(*)`; registra la cifra observada sin extraer el producto completo.
- **30%:** Reescribe el reporte uniendo cada movimiento con su cuenta y después con su titular. Filtra clientes activos y movimientos desde 100, proyecta correo, cuenta, tipo, importe y fecha, y añade un orden estable.
- **20%:** Comprueba el resultado con datos reproducibles: Los recuentos de la semilla son 4, 5 y 4: el producto es 80. El reporte con claves muestra tres eventos de al menos 100, no 80 operaciones.
- **15%:** Reconoce las dos uniones necesarias, distingue su efecto del filtro y evita un orden que omita el desempate temporal.
