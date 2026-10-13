--Actividad 11: Transformaciones escalares y fechas de OmniBank

--1.-Reporte de las 5 cuentas y sus titulares
SELECT 
    c.email,
    a.account_number,
    UPPER(c.first_name) || ' ' || UPPER(c.last_name) AS titular_mayusculas,
    'CUENTA-' || RIGHT(a.account_number, 4) AS etiqueta_cuenta,
    a.account_type,
    a.balance,
    CASE 
        WHEN a.is_active = false THEN 'ESTATUS: DESACTIVADA'
        ELSE 'ESTATUS: ACTIVA'
    END AS descripcion_estado
FROM 
    core.accounts a
INNER JOIN 
    core.customers c ON a.customer_id = c.customer_id
ORDER BY 
    a.account_number ASC;

--2.-Reporte de los 4 eventos anteriores al corte indicado
SELECT 
    t.transaction_id,
    t.amount AS importe_original,
    TO_CHAR(t.amount, 'FM$999,999.00') AS importe_presentacion,
    t.created_at AS marca_tiempo_original,
    EXTRACT(YEAR FROM t.created_at) AS anio_operacion,
    EXTRACT(MONTH FROM t.created_at) AS mes_operacion,
    t.created_at + INTERVAL '15 days' AS fecha_revision_calculada
FROM 
    core.transactions t
WHERE 
    t.created_at < TIMESTAMPTZ '2026-09-10 00:00:00+00'
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;

--3.-Controles de recuento de las funtes
SELECT COUNT(*) AS total_cuentas_origen FROM core.accounts;

SELECT COUNT(*) AS total_transacciones_origen FROM core.transactions;