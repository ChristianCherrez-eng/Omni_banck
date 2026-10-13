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