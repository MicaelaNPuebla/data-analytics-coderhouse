-- Módulo 3 - Diseño de esquema con DDL
-- Archivo: modulo2_unidad1_diseno.sql
-- Autor: Micaela Puebla

-- Limpieza previa: permite re-ejecutar el script sin errores
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- Tabla de Clientes
CREATE TABLE clientes (
id_cliente INT,         -- Identificador numérico
nombre VARCHAR (60),    -- Texto corto con límite conocido
perfil_bio TEXT,        -- Texto largo de longitud impredecible
fecha_registro DATE     -- Sólo fecha, sin hora
);

-- Tabla de Productos
CREATE TABLE productos (
id_producto INT,             -- Identificador numérico entero
descripcion VARCHAR (255),   -- Texto con límite conocido (255 caracteres)
precio DECIMAL (10,2),       -- Monetario: 10 dígitos, 2 decimales; nunca FLOAT
esta_activo BOOLEAN          -- Dos estados en PostgreSQL: TRUE=activo / FALSE=inactivo
);