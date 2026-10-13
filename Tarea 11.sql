--Tarea 11: Porcentaje de cuentas desactivadas y ventana de revisión temporal

--1.-Porcentaje de cuentas desactivadas
SELECT 
    COUNT(*) AS total_cuentas,
    COUNT(*) FILTER (WHERE is_active = false) AS cuentas_desactivadas,
    ROUND(
        (COUNT(*) FILTER (WHERE is_active = false)::NUMERIC / COUNT(*)::NUMERIC) * 100, 
        2
    ) AS porcentaje_desactivadas
FROM 
    core.accounts;

--2.-Ventana temporal y antiguedad al corte
SELECT 
    t.transaction_id,
    t.created_at AS tx_timestamp,
    t.created_at + INTERVAL '15 days' AS fecha_revision_calculada,
    TIMESTAMPTZ '2026-10-01 00:00:00+00' AS fecha_corte_fija,
    AGE(TIMESTAMPTZ '2026-10-01 00:00:00+00', t.created_at) AS antiguedad_al_corte
FROM 
    core.transactions t
WHERE 
    t.created_at < TIMESTAMPTZ '2026-10-01 00:00:00+00'
ORDER BY 
    t.created_at ASC, 
    t.transaction_id ASC;