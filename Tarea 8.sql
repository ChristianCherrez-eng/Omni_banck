--Tarea 8: Auditoría Antifraude y Detección de Operaciones Sospechosas (AML) en OmniBank

--1.-El Blindaje por Precedencia Combinatoria de Operadores:
SELECT 
    transaction_id,
    amount,
    tx_type,
    created_at AS tx_timestamp,
    COALESCE(description, 'EXCLUSIÓN OPORTUNAMENTE DETECTADA - SIN MOTIVO DE PAGO') AS descripcion_monitoreada
FROM 
    core.transactions

--2.-El Siguiente Nivel Empresarial: Purga del String Vacío (NULLIF):
WHERE 
    (amount >= 10000.00 AND tx_type IN ('TRANSFER', 'WITHDRAWAL'))
    OR description ILIKE '%crypto%'
    OR description ILIKE '%offshore%'
    OR description ILIKE '%shell%'
    OR description ILIKE '%casino%'
    OR (NULLIF(TRIM(description), '') IS NULL AND tx_type != 'DEPOSIT')

--3.-Presentación Gerencial Limpia (COALESCE + Proyección Quirúrgica):
ORDER BY 
    amount DESC;