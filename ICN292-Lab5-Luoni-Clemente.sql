-- ============================================================
--  Lab 5 - Andes Bike
--  ICN292 - Sistemas de Información para la Gestión
-- ============================================================

-- Crear y seleccionar la base
DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

-- ============================================================
--  TABLAS
-- ============================================================

-- Tabla base
CREATE TABLE tiendas (
    id_tienda   INT AUTO_INCREMENT,
    nombre      VARCHAR(60) NOT NULL,
    comuna      VARCHAR(50),
    PRIMARY KEY (id_tienda)
);

-- Vendedores, con clave foránea hacia tiendas
CREATE TABLE vendedores (
    id_vendedor    INT AUTO_INCREMENT,
    nombre         VARCHAR(80) NOT NULL,
    id_tienda      INT,
    fecha_ingreso  DATE,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda)
);

-- Catálogo de modelos
CREATE TABLE bicicletas (
    id_bicicleta  INT AUTO_INCREMENT,
    modelo        VARCHAR(60) NOT NULL,
    categoria     ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio        DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_bicicleta)
);

-- Ventas, con clave foránea hacia vendedores y bicicletas
CREATE TABLE ventas (
    id_venta      INT AUTO_INCREMENT,
    id_vendedor   INT,
    id_bicicleta  INT,
    fecha         DATE,
    unidades      INT,
    PRIMARY KEY (id_venta),
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas(id_bicicleta)
);

-- ============================================================
--  CARGA OFICIAL
-- ============================================================

INSERT INTO tiendas (nombre, comuna) VALUES
('Andes Providencia', 'Providencia'),   -- 1
('Andes Maipú',       'Maipú'),         -- 2
('Andes Concepción',  'Concepción'),    -- 3
('Andes La Serena',   'La Serena');     -- 4  <-- sin vendedores

INSERT INTO vendedores (nombre, id_tienda, fecha_ingreso) VALUES
('Camila Ortiz',    1, '2024-06-20'),   -- 1
('Diego Fuentes',   1, '2024-01-15'),   -- 2
('Javiera Soto',    2, '2023-07-24'),   -- 3
('Matías Herrera',  2, '2024-01-15'),   -- 4
('Paula Riquelme',  3, '2022-11-02'),   -- 5
('Ignacio Vera',    3, '2024-08-19'),   -- 6
('Fernanda Lillo',  1, '2025-02-03'),   -- 7
('Rubén Castro', NULL, '2025-06-10');   -- 8  <-- sin tienda

INSERT INTO bicicletas (modelo, categoria, precio) VALUES
('Cordillera 29',  'Montaña',    549990.00),   -- 1
('Ruta Austral',   'Ruta',       899990.00),   -- 2
('Urbana Pro',     'Urbana',     329990.00),   -- 3
('Pequeño Andes',  'Infantil',   149990.00),   -- 4
('Volt City',      'Eléctrica', 1249990.00),   -- 5
('Trail Master',   'Montaña',    749990.00),   -- 6
('Urbana Lite',    'Urbana',     229990.00),   -- 7
('Sprint R7',      'Ruta',      1099990.00);   -- 8

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1, 5, '2025-04-02', 1),
(2, 2, '2025-03-04', 1),
(2, 1, '2025-04-11', 3),
(2, 7, '2025-05-06', 2),
(3, 4, '2025-03-21', 4),
(3, 3, '2025-04-15', 2),
(3, 6, '2025-05-20', 1),
(4, 1, '2025-03-27', 1),
(4, 5, '2025-05-09', 2),
(5, 2, '2025-04-08', 1),
(5, 6, '2025-04-23', 2),
(5, 4, '2025-06-02', 5),
(6, 3, '2025-05-13', 3),
(6, 7, '2025-06-17', 1),
(6, 1, '2025-06-24', 2),
(1, 6, '2025-06-30', 1);

SELECT * FROM vendedores;

-- ============================================================
--  CONSULTAS
-- ============================================================

-- Consulta 1
-- Ventas por vendedor, incluidos los que no tienen ninguna
SELECT   v.nombre, COUNT(ve.id_venta) AS ventas
FROM     vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY ventas DESC, v.nombre;

-- Consulta 2
-- Ventas y unidades por tienda, incluida la que no tiene vendedores
SELECT   t.nombre AS tienda,
         COUNT(ve.id_venta) AS ventas,
         SUM(ve.unidades)   AS unidades
FROM     tiendas t
LEFT JOIN vendedores v ON t.id_tienda   = v.id_tienda
LEFT JOIN ventas ve    ON v.id_vendedor = ve.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades DESC;

-- Consulta 3
-- Tiendas que no tienen ningún vendedor
SELECT t.nombre
FROM   tiendas t
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
WHERE  v.id_vendedor IS NULL;

-- Consulta 4
-- Modelos que no se vendieron en junio de 2025
SELECT b.modelo
FROM   bicicletas b
LEFT JOIN ventas ve ON b.id_bicicleta = ve.id_bicicleta
	  AND ve.fecha BETWEEN '2025-06-01' AND '2025-06-30'
WHERE  ve.id_venta IS NULL;

-- Consulta 5
-- Vendedores sin ventas, con el nombre de su tienda
SELECT v.nombre, t.nombre AS tienda
FROM   vendedores v
LEFT JOIN tiendas t ON v.id_tienda   = t.id_tienda
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
WHERE  ve.id_venta IS NULL;

-- Consulta 6
-- Pares de vendedores de la misma tienda, primero el que entró antes
SELECT v1.nombre        AS vendedor_1,
       v1.fecha_ingreso AS ingreso_1,
       v2.nombre        AS vendedor_2,
       v2.fecha_ingreso AS ingreso_2,
       t.nombre         AS tienda
FROM   vendedores v1
JOIN   vendedores v2 ON v1.id_tienda     = v2.id_tienda
                    AND v1.fecha_ingreso < v2.fecha_ingreso
JOIN   tiendas t     ON v1.id_tienda     = t.id_tienda
ORDER BY t.nombre, v1.fecha_ingreso;

-- Consulta 7
-- Monto en Montaña y Ruta por tienda, solo las que pasan los 2.000.000
SELECT   t.nombre AS tienda,
         SUM(ve.unidades * b.precio) AS monto
FROM     tiendas t
JOIN     vendedores v  ON t.id_tienda    = v.id_tienda
JOIN     ventas ve     ON v.id_vendedor  = ve.id_vendedor
JOIN     bicicletas b  ON ve.id_bicicleta = b.id_bicicleta
WHERE    b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING   monto > 2000000
ORDER BY monto DESC;

-- Consulta 8
-- Promedio de precios del catálogo
SELECT AVG(precio) AS promedio
FROM   bicicletas;

-- Bicicletas sobre el promedio, de mayor a menor
SELECT   modelo, precio
FROM     bicicletas
WHERE    precio > (SELECT AVG(precio)
                   FROM bicicletas)
ORDER BY precio DESC;

-- Consulta 9
-- Vendedores con promedio de unidades sobre el de toda la cadena
SELECT   v.nombre, AVG(ve.unidades) AS promedio
FROM     vendedores v
JOIN     ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING   promedio > (SELECT AVG(unidades)
                     FROM ventas)
ORDER BY promedio DESC, v.nombre;

-- Consulta 10
-- Monto vendido por cada vendedor, incluidos los que no vendieron
SELECT   v.nombre, SUM(ve.unidades * b.precio) AS monto
FROM     vendedores v
LEFT JOIN ventas ve    ON v.id_vendedor   = ve.id_vendedor
LEFT JOIN bicicletas b ON ve.id_bicicleta = b.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto DESC;