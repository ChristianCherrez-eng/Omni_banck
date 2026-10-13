--Actividad 9: reportes relacionales para operaciones de OmniBank

--1.-Punto de control de la semilla.
SELECT 
    (SELECT COUNT(*) FROM core.customers) AS total_customers,
    (SELECT COUNT(*) FROM core.accounts) AS total_accounts,
    (SELECT COUNT(*) FROM core.transactions) AS total_transactions;

--2.-Recorrido de cada movimiento.
SELECT 
    t.transaction_id,
    c.first_name,
    c.last_name,
    a.account_number,
    t.tx_type,
    t.amount
FROM 
    core.transactions t
INNER JOIN 
    core.accounts a ON t.account_id = a.account_id
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;

--3.-Cuentas sin movimientos.
SELECT 
    a.account_number,
    a.is_active,
    CASE 
        WHEN a.is_active = false THEN 'CUENTA DESACTIVADA SIN ACTIVIDAD'
        ELSE 'CUENTA ACTIVA - SIN MOVIMIENTOS REGISTRADOS'
    END AS etiqueta_presentacion
FROM 
    core.accounts a
LEFT JOIN 
    core.transactions t ON a.account_id = t.account_id
WHERE 
    t.transaction_id IS NULL;

--4.-Titulares con cuenta elegible, si existe.
SELECT 
    cust.email,
    acc.account_number,
    acc.balance
FROM 
    core.customers cust
LEFT JOIN 
    core.accounts acc ON cust.customer_id = acc.customer_id AND acc.balance > 0.00;


Lo que aprendi: : Ajusté los conectores JOIN para evitar cruces erróneos de datos, 
tal como lo señalaba la guía del maestro.  


Fix: # Day 09 Answer Key — Relaciones Reales y Ausencia de Movimientos

## Expected Result

El checkpoint aporta cuatro clientes, cinco cuentas y cuatro movimientos. El recorrido de eventos devuelve cuatro filas; la consulta de ausencia devuelve ACCT-1002 desactivada y ACCT-3002 activa. El reporte de titulares con balance > 0 conserva a los cuatro clientes, con columnas de cuenta nulas para Alice y Humberto. La variante con el filtro en `WHERE` pierde esas dos personas.

## Reference Solution

```sql
SELECT (SELECT COUNT(*) FROM core.customers) AS customers,
       (SELECT COUNT(*) FROM core.accounts) AS accounts,
       (SELECT COUNT(*) FROM core.transactions) AS movements;

SELECT t.transaction_id, c.first_name, c.last_name, a.account_number, t.tx_type, t.amount
FROM core.transactions t
JOIN core.accounts a ON a.account_id = t.account_id
JOIN core.customers c ON c.customer_id = a.customer_id
ORDER BY t.tx_timestamp, t.transaction_id;

SELECT a.account_number, a.is_active,
       CASE WHEN a.is_active THEN 'ACTIVA SIN MOVIMIENTOS'
            ELSE 'DESACTIVADA SIN MOVIMIENTOS' END AS estado
FROM core.accounts a
LEFT JOIN core.transactions t ON t.account_id = a.account_id
WHERE t.transaction_id IS NULL
ORDER BY a.account_number;

SELECT c.email, a.account_number, a.balance
FROM core.customers c
LEFT JOIN core.accounts a
  ON a.customer_id = c.customer_id AND a.balance > 0
ORDER BY c.email, a.account_number;

-- Comparación diagnóstica: WHERE elimina las filas externas sin pareja elegible.
SELECT c.email, a.account_number, a.balance
FROM core.customers c
LEFT JOIN core.accounts a ON a.customer_id = c.customer_id
WHERE a.balance > 0
ORDER BY c.email, a.account_number;
```

La última consulta devuelve solo John y Jane; si se requiere preservar a los titulares, el predicado de cuenta elegible pertenece a `ON`. `is_active` y ausencia de movimiento son atributos diferentes y no deben codificarse en el enum `tx_type`.

## Common Valid Variations

* Se aceptan alias distintos, una etiqueta textual equivalente y un `RIGHT JOIN` reorientado que preserve las mismas cuentas. 
* Una solución con `NOT EXISTS` para la ausencia también es válida si está claramente explicada, aunque no se exige antes del día 12.

## Common Mistakes

* **Unir movimiento con cliente por un campo descriptivo**: Hacerlo en vez de recorrer las claves foráneas crea asociaciones falsas.
* **Filtrar `transactions` en `WHERE` después de un `LEFT JOIN`**: Puede ocultar cuentas sin eventos inadvertidamente.
* **Usar un `INNER JOIN` entre clientes y cuentas**: Elimina a Humberto del reporte.
* **Filtrar `balance` en `WHERE`**: Elimina también a Alice del reporte.

## Grading Rubric

* **25%**: Recuentos de control y uso de claves reales (`account_id` y `customer_id`).
* **25%**: Recorrido de cuatro movimientos, una fila por evento y orden estable.
* **25%**: Ausencia de dos cuentas con `is_active` separado de la existencia de eventos.
* **25%**: Cuatro titulares preservados, comparación entre predicados en `ON` vs `WHERE` y explicación del grano.