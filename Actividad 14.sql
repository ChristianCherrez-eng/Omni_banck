--Actividad 14: Self JOIN, matriz de productos y anti JOIN

SELECT 
    t1.account_id,
    t1.transaction_id AS tx_primera,
    t1.created_at AS fecha_primera,
    t1.amount AS importe_primera,
    t2.transaction_id AS tx_segunda,
    t2.created_at AS fecha_segunda,
    t2.amount AS importe_segunda,
    t2.created_at - t1.created_at AS intervalo_temporal
FROM 
    core.transactions t1
INNER JOIN 
    core.transactions t2 ON t1.account_id = t2.account_id
WHERE 
    t1.transaction_id < t2.transaction_id -- Evita duplicados inversos y emparejamientos consigo misma
    AND t2.created_at - t1.created_at <= INTERVAL '48 hours'
ORDER BY 
    t1.account_id ASC, 
    t1.transaction_id ASC;
WITH tipos_cuenta AS (
        SELECT UNNEST(ARRAY['CHECKING', 'SAVINGS', 'CREDIT']) AS account_type
),
matriz_posibilidades AS (
        SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS titular,
        c.email,
        t.account_type
    FROM 
        core.customers c
    CROSS JOIN 
        tipos_cuenta t
)
SELECT 
    mp.customer_id,
    mp.titular,
    mp.email,
    mp.account_type AS tipo_cuenta_faltante
FROM 
    matriz_posibilidades mp
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM core.accounts a 
        WHERE a.customer_id = mp.customer_id 
          AND a.account_type = mp.account_type
    )
ORDER BY 
    mp.customer_id ASC, 
    mp.account_type ASC;
SELECT COUNT(*) AS total_posibilidades_matriz 
FROM core.customers 
CROSS JOIN (SELECT UNNEST(ARRAY['CHECKING', 'SAVINGS', 'CREDIT'])) AS t(account_type);
SELECT COUNT(*) AS total_cuentas_registradas 
FROM core.accounts;


Lo que aprendi:  Afiné la comparación de tiempos entre eventos y la tabla cruzada 
siguiendo los filtros específicos de la solución del profe. 


Fix: # Day 14 Answer Key — Self JOIN, matriz de productos y anti JOIN

## Expected Result
John ofrece un par de movimientos iniciales en la misma cuenta. La matriz muestra posibilidades faltantes sin inventar sucursales ni relaciones por moneda.

## Reference Solution
```sql
SELECT t1.account_id, t1.transaction_id AS earlier_id, t2.transaction_id AS later_id
FROM core.transactions t1 JOIN core.transactions t2
 ON t1.account_id = t2.account_id
 AND (t1.tx_timestamp,t1.transaction_id) < (t2.tx_timestamp,t2.transaction_id)
 AND t2.tx_timestamp <= t1.tx_timestamp + INTERVAL '48 hours'
ORDER BY t1.account_id, t1.tx_timestamp;

WITH types AS (
 SELECT unnest(enum_range(NULL::core.tipo_cuenta)) AS account_type
)
SELECT c.customer_id, c.email, ty.account_type
FROM core.customers c CROSS JOIN types ty
LEFT JOIN core.accounts a ON a.customer_id = c.customer_id AND a.account_type = ty.account_type
WHERE a.account_id IS NULL 
ORDER BY c.email, ty.account_type;