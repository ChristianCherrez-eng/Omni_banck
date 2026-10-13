--Actividad 8: Extracción de Reportes Gerenciales en OmniBank y Detección de Vacíos

--Reporte 1: Extracción Quirúrgica de Cuentas Prioritarias:
SELECT 
    account_number, 
    account_type, 
    balance
FROM 
    core.accounts
WHERE 
    balance >= 1000.00 
    OR account_type = 'SAVINGS'
ORDER BY 
    balance DESC
LIMIT 2;

--Reporte 2: Búsqueda Insensible por Patrones en Clientes:
SELECT 
    first_name, 
    last_name, 
    email
FROM 
    core.customers
WHERE 
    email ILIKE '%@email.com';
--Reporte 3: El Desmantelamiento del Fallo por Nulidad (Lógica Tri-Valuada):
SELECT 
    transaction_id,
    account_id,
    amount,
    tx_type,
    COALESCE(description, 'COBRO INSTITUCIONAL O COMISIÓN - SIN RECEPTOR') AS descripcion_visible
FROM 
    core.transactions
WHERE 
    description IS NULL;


Lo que aprendi: Corregí los filtros de texto y los campos faltantes siguiendo la 
estructura de reportes que pedía el maestro. 


Fix: # Day 08 Answer Key — Extracción de Reportes Gerenciales en OmniBank y Detección de Vacíos

## Expected Result
El estudiante entregará en formato de guion SQL (`query_01_core_retrieval.sql`) tres reportes analíticos para OmniBank sin incurrir al anti-patrón de comodín (`SELECT *`), aplicando filtros condicionales combinados, búsquedas difusivas sin sensibilidad con `ILIKE` y resolviendo la Lógica Tri-Valuada en el tratamiento de vacíos interbancarios sustituyendo el ilegal `= NULL` por `IS NULL` y proyectando confirmaciones pulidas con `COALESCE`.

## Reference Solution

### 1. Guion SQL de Extracción Gerencial (`query_01_core_retrieval.sql`)
```sql
-- REPORTE 1: Extracción Quirúrgica de Cuentas Prioritarias en OmniBank
-- Excluye celdas ruidosas (UUIDs, created_at, etc.) mediante proyección explícita
SELECT 
    account_number,
    account_type,
    balance
FROM core.accounts
WHERE (balance >= 1000.00 OR account_type = 'SAVINGS')
ORDER BY balance DESC
LIMIT 2;

-- REPORTE 2: Búsqueda Insensible por Patrones en Clientes Bancarios
-- Atrapa por igual '@email.com', '@EMAIL.COM' sin alterar el motor
SELECT 
    first_name,
    last_name,
    email
FROM core.customers
WHERE email ILIKE '%@email.com';

-- REPORTE 3: Resolución de la Lógica Tri-Valuada y Salvaguarda con COALESCE
-- Corrige el fallo del analista interino (= NULL -> IS NULL) y purga vacíos
SELECT 
    account_id,
    amount,
    tx_type,
    COALESCE(description, 'COBRO INSTITUCIONAL O COMISIÓN - SIN RECEPTOR') AS descripcion_visible
FROM core.transactions
WHERE description IS NULL AND tx_type = 'WITHDRAWAL';
```

## Common Valid Variations
- En el Reporte 1, incluir adicionalmente o no la cláusula combinacional de comprobación `AND is_active = true` al final del paréntesis no resta mérito o puntaje evaluativo en modo alguno siempre que la jerarquía relacional se preserve.
- En el Reporte 3, prescindir del filtro adicional opcional `AND tx_type = 'WITHDRAWAL'` es completamente válido, puesto que la directriz fundamental es aplicar la evaluación de `IS NULL`.

## Common Mistakes
- **Haber recurrido por indolencia a proyectar el asterisco (`SELECT *`)** en las cabeceras de cualquiera de los reportes: Infringe las directrices no negociables de la actividad para prevención y protección por *Over-fetching*.
- **Mantener el operador de igualdad o diferenciamiento ordinario** (`description = NULL` / `!= NULL`): Se califica con el mayor nivel de severidad por parte de los revisores computados y pedagógicos, demostrando un nulo dominio frente a la Lógica Tri-Valuada elemental de bases de datos relacionales.
- **Omitir los paréntesis combinatorios** al mezclar condicionales `AND` / `OR`: Si un alumno intentó anexar algún otro criterio de exclusión o estado activo en el primer reporte sin encapsulamiento operatorio en los paréntesis, arruinó por precedencia matemática incorrecta la autenticidad transaccional del reporte final devuelto en su consola. 