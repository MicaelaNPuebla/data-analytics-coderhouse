-- ══════════════════════════════════════════
-- Módulo 4 — Consultas SQL de negocio
-- Autor: Micaela Puebla
-- Fecha: 2026-08-19
-- ══════════════════════════════════════════

-- SECCIÓN DDL
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

CREATE TABLE categorias (
id_categoria INT PRIMARY KEY,
nombre_categoria VARCHAR(50) NOT NULL,
descripcion VARCHAR(200)
);
CREATE TABLE clientes (
id_cliente INT PRIMARY KEY,
nombre VARCHAR (100) NOT NULL,
email VARCHAR (100) UNIQUE,
ciudad VARCHAR (50),
fecha_registro DATE NOT NULL
);
CREATE TABLE productos (
id_producto INT PRIMARY KEY,
nombre_producto VARCHAR(100) NOT NULL,
id_categoria INT REFERENCES categorias(id_categoria),
precio DECIMAL(10,2) NOT NULL,
stock INT DEFAULT 0,
activo SMALLINT DEFAULT 1
);
CREATE TABLE ventas (
id_venta INT PRIMARY KEY,
id_cliente INT REFERENCES clientes (id_cliente),
id_producto INT REFERENCES productos (id_producto),
cantidad INT NOT NULL,
precio_unitario    DECIMAL(10,2)    NOT NULL,
fecha_venta DATE NOT NULL
);

-- SECCIÓN DML
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion)
VALUES
(1, 'Computación', 'Laptops, PCs y monitores'),
(2, 'Accesorios', 'Periféricos y complementos'),
(3, 'Audio', 'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
VALUES
(1, 'María López', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruiz', 'carlos@mail.com', 'Córdoba', '2024-01-10'),
(3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01'),
(4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES
(1, 'Laptop Pro 15', 1, 1200.00, 15, 1),
(2, 'Mouse Inalámbrico', 2,   28.00, 80, 1),
(3, 'Monitor 4K 27"', 1, 450.00, 12, 1),
(4, 'Auriculares BT Pro', 3, 120.00, 35, 1),
(5, 'SSD Externo 1TB', 4, 130.00, 18, 1),
(6, 'Teclado Mecánico', 2, 95.00, 40, 1);
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
VALUES
(1,  1, 1, 2, 1200.00, '2024-03-05'),
(2,  2, 2, 5, 28.00, '2024-03-06'),
(3,  3, 3, 1, 450.00, '2024-03-07'),
(4,  1, 4, 2, 120.00, '2024-03-08'),
(5,  4, 5, 3, 130.00, '2024-03-10'),
(6,  2, 6, 4, 95.00, '2024-03-11'),
(7,  5, 1, 1, 1200.00, '2024-03-12'),
(8,  3, 2, 8, 28.00, '2024-03-13'),
(9,  4, 4, 1, 120.00, '2024-03-14'),
(10, 5, 3, 2, 450.00, '2024-03-15');

-- Validación: ver la tabla completa
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

--Las 5 agregaciones de la tabla ventas
SELECT COUNT(*) AS total_ventas FROM ventas;
SELECT SUM(cantidad*precio_unitario) AS monto_total FROM ventas;
SELECT AVG(cantidad * precio_unitario) AS ticket_promedio FROM ventas;
SELECT MAX(cantidad * precio_unitario) AS venta_maxima FROM ventas;
SELECT MIN(cantidad * precio_unitario) AS venta_minima FROM ventas;

--Resumen ejecutivo mensual 
SELECT
EXTRACT (MONTH FROM fecha_venta) AS mes,
SUM(cantidad * precio_unitario) AS total_facturado,
COUNT(*) AS cantidad_pedidos,
AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;

--Ranking de productos
SELECT
id_producto,
SUM(cantidad) AS unidades_vendidas,
SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;

--Clientes recurrentes
SELECT
id_cliente,
COUNT(*) AS cantidad_pedidos,
SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;

--Meses por encima/por debajo del promedio (sólo hay datos de marzo)
SELECT
EXTRACT(MONTH FROM fecha_venta) AS mes,
SUM(cantidad * precio_unitario) AS total_mes,
CASE
WHEN SUM(cantidad * precio_unitario) > (
SELECT AVG(total_mes)
FROM (
SELECT SUM(cantidad * precio_unitario) AS total_mes
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
) AS totales_por_mes
) THEN 'Por encima'
WHEN SUM(cantidad * precio_unitario) < (
SELECT AVG(total_mes)
FROM (
SELECT SUM(cantidad * precio_unitario) AS total_mes
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
) AS totales_por_mes
) THEN 'Por debajo'
ELSE 'En el promedio'
END AS comparacion
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;

--Bloque de cierre: 3 hallazgos concretos que encontré al revisar los resultados:

-- 1. El producto 1 lidera la facturación con $3.600 vendiendo sólo 3 unidades,
--    mientras que el producto 2 vendió 13 unidades, pero facturó apenas $364.

--    La facturación no depende del volumen, sino del precio del producto.

-- 2. El cliente 1 gastó 2640, cinco veces más que el cliente 4 (510),
--    aunque ambos hicieron la misma cantidad de pedidos (2).

--    Mismo número de compras, valor muy distinto.

-- 3. Toda la facturación ($6.444) y las 10 ventas se concentran en marzo.
--    No hay datos de otros meses, lo que impide analizar tendencia o estacionalidad.

--    Como analista, esto sugiere revisar si el dataset está completo antes de
--    sacar conclusiones sobre el comportamiento temporal del negocio.