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



Lo que aprendi: Reacomodé los paréntesis en las condiciones lógicas tal como venía 
en la solución del profesor para evitar falsas alarmas.  


Fix: # Day 08 Answer Key — Candidatos de Revisión

## Expected Result

Tres movimientos de revisión didáctica, sin atribuir fraude ni destinatario.

## Reference Solution

```sql
SELECT 
    transaction_id,
    account_id,
    tx_type,
    amount,
    COALESCE(NULLIF(TRIM(description), ''), 'SIN DESCRIPCIÓN') AS visible_description
FROM core.transactions
WHERE (tx_type IN ('TRANSFER', 'WITHDRAWAL') AND amount >= 100)
   OR (tx_type = 'WITHDRAWAL' AND NULLIF(TRIM(description), '') IS NULL)
ORDER BY amount DESC, transaction_id;
```

Los dos `TRANSFER` superan el umbral didáctico. El retiro de 50 entra por descripción faltante. El depósito no cumple ninguno de los dos bloques. Una alerta exploratoria requiere revisión adicional y no constituye una acusación ni un reporte legal.

## Common Valid Variations

* Se acepta `btrim` y una CTE que calcule la descripción normalizada antes de filtrar.

## Common Mistakes

* **Omitir paréntesis**: Cambia la precedencia de los operadores lógicos y altera los resultados esperados.
* **Tratar `description IS NULL` como prueba de fraude**: Confunde una observación incompleta o un dato faltante con una conclusión delictiva.