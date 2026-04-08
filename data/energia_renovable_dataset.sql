-- ============================================================
--  DATASET: Energías Renovables — Curso SQL con PostgreSQL
--  Autor: Generado para práctica de SQL
--  Base de datos: energia_renovable
-- ============================================================

-- Eliminar tablas si ya existen (para poder volver a cargar)
DROP TABLE IF EXISTS incidencias CASCADE;
DROP TABLE IF EXISTS mantenimiento CASCADE;
DROP TABLE IF EXISTS produccion CASCADE;
DROP TABLE IF EXISTS plantas_renovables CASCADE;
DROP TABLE IF EXISTS tecnologias CASCADE;
DROP TABLE IF EXISTS provincias CASCADE;

-- ============================================================
-- TABLA 1: provincias
-- ============================================================
CREATE TABLE provincias (
    id_provincia   SERIAL PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL,
    comunidad      VARCHAR(60) NOT NULL,
    horas_sol_anuales INT
);

INSERT INTO provincias (nombre, comunidad, horas_sol_anuales) VALUES
('Sevilla',    'Andalucía',          3000),
('Badajoz',    'Extremadura',        2900),
('Jaén',       'Andalucía',          2800),
('Albacete',   'Castilla-La Mancha', 2750),
('Zaragoza',   'Aragón',             2600),
('Valladolid', 'Castilla y León',    2400),
('Burgos',     'Castilla y León',    2200),
('Cádiz',      'Andalucía',          2950),
('Murcia',     'Murcia',             2900),
('Navarra',    'Navarra',            2100);


-- ============================================================
-- TABLA 2: tecnologias
-- ============================================================
CREATE TABLE tecnologias (
    id_tecnologia  SERIAL PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL,
    descripcion    TEXT,
    madurez        VARCHAR(20) CHECK (madurez IN ('consolidada','emergente','experimental'))
);

INSERT INTO tecnologias (nombre, descripcion, madurez) VALUES
('Solar fotovoltaica',    'Conversión directa de luz solar en electricidad mediante paneles',         'consolidada'),
('Eólica terrestre',      'Aprovechamiento del viento mediante aerogeneradores en tierra',            'consolidada'),
('Eólica marina',         'Aerogeneradores instalados en plataformas sobre el mar',                   'emergente'),
('Solar termoeléctrica',  'Concentración de radiación solar para generar vapor y electricidad',       'consolidada'),
('Hidroeléctrica',        'Aprovechamiento del flujo de agua para generar electricidad',              'consolidada'),
('Biomasa',               'Combustión de materia orgánica para generar calor y electricidad',         'consolidada'),
('Geotérmica',            'Aprovechamiento del calor interno de la Tierra',                           'emergente'),
('Hidrógeno verde',       'Producción de hidrógeno mediante electrólisis con energía renovable',      'experimental');


-- ============================================================
-- TABLA 3: plantas_renovables
-- ============================================================
CREATE TABLE plantas_renovables (
    id_planta       SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    id_provincia    INT REFERENCES provincias(id_provincia),
    id_tecnologia   INT REFERENCES tecnologias(id_tecnologia),
    potencia_mw     DECIMAL(8,2) NOT NULL,
    fecha_inicio    DATE NOT NULL,
    inversión_meur  DECIMAL(8,2),
    num_empleados   INT,
    activa          BOOLEAN DEFAULT TRUE
);

INSERT INTO plantas_renovables (nombre, id_provincia, id_tecnologia, potencia_mw, fecha_inicio, inversión_meur, num_empleados, activa) VALUES
('Solar Sevilla Norte',       1, 1, 150.0, '2019-04-10', 120.5, 45,  TRUE),
('Solar Sevilla Sur',         1, 1,  80.5, '2021-06-15',  64.0, 28,  TRUE),
('Termosolar Las Marismas',   1, 4, 200.0, '2017-09-01', 380.0, 120, TRUE),
('Solar Badajoz Oeste',       2, 1, 120.0, '2020-03-22',  96.0, 38,  TRUE),
('Solar Extremadura I',       2, 1,  60.0, '2022-11-05',  48.0, 22,  TRUE),
('Eólica Jaén Sierra',        3, 2,  90.0, '2018-07-14',  81.0, 32,  TRUE),
('Solar Jaén Valle',          3, 1,  45.0, '2023-02-28',  36.0, 18,  TRUE),
('Eólica Albacete I',         4, 2, 110.0, '2016-05-30',  99.0, 40,  TRUE),
('Eólica Albacete II',        4, 2,  75.0, '2020-10-18',  67.5, 27,  TRUE),
('Solar Zaragoza Este',       5, 1,  95.0, '2021-08-12',  76.0, 33,  TRUE),
('Eólica Zaragoza Norte',     5, 2, 130.0, '2019-11-20', 117.0, 48,  TRUE),
('Eólica Valladolid I',       6, 2,  55.0, '2015-03-08',  49.5, 20,  TRUE),
('Biomasa Valladolid',        6, 6,  25.0, '2018-01-15',  37.5, 35,  TRUE),
('Eólica Burgos Sierra',      7, 2,  85.0, '2017-06-22',  76.5, 30,  TRUE),
('Solar Cádiz Costa',         8, 1, 100.0, '2022-04-01',  80.0, 36,  TRUE),
('Eólica Murcia Sur',         9, 2,  70.0, '2020-09-15',  63.0, 25,  TRUE),
('Solar Murcia Inland',       9, 1,  88.0, '2023-07-10',  70.4, 31,  TRUE),
('Eólica Navarra Pirineo',   10, 2, 160.0, '2014-12-01', 144.0, 55,  TRUE),
('Biomasa Navarra',          10, 6,  18.0, '2019-05-20',  27.0, 28,  FALSE),
('Solar Sevilla Piloto',      1, 1,  10.0, '2024-01-20',   8.5, 8,   TRUE);


-- ============================================================
-- TABLA 4: produccion (datos diarios por planta, años 2023-2024)
-- ============================================================
CREATE TABLE produccion (
    id_produccion   SERIAL PRIMARY KEY,
    id_planta       INT REFERENCES plantas_renovables(id_planta),
    fecha           DATE NOT NULL,
    kwh_producidos  DECIMAL(12,2) NOT NULL,
    horas_operacion DECIMAL(4,1),
    irradiancia_whm2 DECIMAL(8,2)
);

-- Generamos producción para todas las plantas activas durante 2023 y 2024
-- Usamos una función para simular variación realista por mes y tecnología
INSERT INTO produccion (id_planta, fecha, kwh_producidos, horas_operacion, irradiancia_whm2)
SELECT
    p.id_planta,
    d::DATE AS fecha,
    ROUND(
        CAST(CASE p.id_tecnologia
            WHEN 1 THEN -- Solar fotovoltaica: depende del mes
                p.potencia_mw * 1000 *
                CASE EXTRACT(MONTH FROM d)
                    WHEN 1 THEN 0.12 WHEN 2 THEN 0.15 WHEN 3 THEN 0.22
                    WHEN 4 THEN 0.28 WHEN 5 THEN 0.32 WHEN 6 THEN 0.38
                    WHEN 7 THEN 0.40 WHEN 8 THEN 0.37 WHEN 9 THEN 0.28
                    WHEN 10 THEN 0.20 WHEN 11 THEN 0.13 WHEN 12 THEN 0.10
                END * (0.85 + RANDOM() * 0.30)
            WHEN 2 THEN -- Eólica terrestre: más uniforme
                p.potencia_mw * 1000 *
                CASE EXTRACT(MONTH FROM d)
                    WHEN 1 THEN 0.28 WHEN 2 THEN 0.30 WHEN 3 THEN 0.25
                    WHEN 4 THEN 0.22 WHEN 5 THEN 0.18 WHEN 6 THEN 0.15
                    WHEN 7 THEN 0.12 WHEN 8 THEN 0.14 WHEN 9 THEN 0.20
                    WHEN 10 THEN 0.26 WHEN 11 THEN 0.30 WHEN 12 THEN 0.32
                END * (0.75 + RANDOM() * 0.50)
            WHEN 4 THEN -- Termosolar
                p.potencia_mw * 1000 *
                CASE EXTRACT(MONTH FROM d)
                    WHEN 1 THEN 0.20 WHEN 2 THEN 0.25 WHEN 3 THEN 0.32
                    WHEN 4 THEN 0.40 WHEN 5 THEN 0.45 WHEN 6 THEN 0.52
                    WHEN 7 THEN 0.55 WHEN 8 THEN 0.50 WHEN 9 THEN 0.40
                    WHEN 10 THEN 0.30 WHEN 11 THEN 0.22 WHEN 12 THEN 0.18
                END * (0.88 + RANDOM() * 0.24)
            ELSE -- Biomasa: constante
                p.potencia_mw * 1000 * 0.75 * (0.90 + RANDOM() * 0.20)
        END AS NUMERIC)
    , 2) AS kwh_producidos,
    ROUND((16 + RANDOM() * 6)::NUMERIC, 1) AS horas_operacion,
    ROUND((300 + RANDOM() * 700)::NUMERIC, 2) AS irradiancia_whm2
FROM
    plantas_renovables p,
    generate_series('2023-01-01'::DATE, '2024-12-31'::DATE, '1 day') d
WHERE
    p.activa = TRUE
    AND p.fecha_inicio <= d;


-- ============================================================
-- TABLA 5: mantenimiento
-- ============================================================
CREATE TABLE mantenimiento (
    id_mantenimiento SERIAL PRIMARY KEY,
    id_planta        INT REFERENCES plantas_renovables(id_planta),
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE,
    tipo             VARCHAR(30) CHECK (tipo IN ('preventivo','correctivo','inspección')),
    descripcion      TEXT,
    coste_eur        DECIMAL(10,2),
    tecnico          VARCHAR(80)
);

INSERT INTO mantenimiento (id_planta, fecha_inicio, fecha_fin, tipo, descripcion, coste_eur, tecnico) VALUES
(1,  '2023-02-10', '2023-02-11', 'preventivo',  'Limpieza de paneles y revisión de inversores',         8500.00,  'Carlos Medina'),
(1,  '2023-09-05', '2023-09-06', 'preventivo',  'Revisión anual de cableado y estructura',              12000.00, 'Ana Ruiz'),
(1,  '2024-03-15', '2024-03-17', 'correctivo',  'Sustitución de inversor averiado (zona C)',            45000.00, 'Carlos Medina'),
(2,  '2023-05-20', '2023-05-20', 'inspección',  'Inspección termográfica de paneles',                   3200.00, 'Laura Jiménez'),
(3,  '2023-07-01', '2023-07-05', 'preventivo',  'Revisión del sistema de seguimiento solar',            22000.00, 'Pedro Vega'),
(3,  '2024-01-10', '2024-01-14', 'correctivo',  'Reparación de bomba de sales fundidas',               180000.00, 'Equipo Externo'),
(6,  '2023-03-12', '2023-03-13', 'preventivo',  'Revisión de palas y sistemas de frenado',             15000.00, 'Miguel Torres'),
(6,  '2023-11-20', '2023-11-22', 'correctivo',  'Sustitución de rodamiento en aerogenerador 4',        38000.00, 'Miguel Torres'),
(8,  '2023-04-08', '2023-04-09', 'preventivo',  'Revisión de góndolas y sistemas eléctricos',          18000.00, 'Sofía Blanco'),
(8,  '2024-06-01', '2024-06-03', 'correctivo',  'Reparación de daños por rayo en aerogenerador 7',     92000.00, 'Equipo Externo'),
(11, '2023-08-15', '2023-08-16', 'inspección',  'Inspección de aspas con dron',                         5500.00, 'Javier Mora'),
(12, '2023-06-10', '2023-06-10', 'preventivo',  'Lubricación y ajuste de mecanismos de orientación',    7200.00, 'Carmen Núñez'),
(14, '2024-02-20', '2024-02-22', 'preventivo',  'Revisión completa post-temporal de nieve',            14000.00, 'Roberto Sainz'),
(18, '2023-10-05', '2023-10-07', 'preventivo',  'Revisión anual completa de parque eólico',            31000.00, 'Elena Gómez'),
(18, '2024-05-12', '2024-05-12', 'inspección',  'Medición de ruido y vibración aerogeneradores',        4800.00, 'Elena Gómez');


-- ============================================================
-- TABLA 6: incidencias
-- ============================================================
CREATE TABLE incidencias (
    id_incidencia   SERIAL PRIMARY KEY,
    id_planta       INT REFERENCES plantas_renovables(id_planta),
    fecha           DATE NOT NULL,
    severidad       VARCHAR(10) CHECK (severidad IN ('baja','media','alta','crítica')),
    tipo            VARCHAR(50),
    descripcion     TEXT,
    horas_parada    DECIMAL(5,1),
    resuelta        BOOLEAN DEFAULT FALSE
);

INSERT INTO incidencias (id_planta, fecha, severidad, tipo, descripcion, horas_parada, resuelta) VALUES
(1,  '2023-03-22', 'media',   'Fallo eléctrico',       'Disparo del diferencial en cuadro principal zona A',   4.5,  TRUE),
(1,  '2024-03-14', 'alta',    'Fallo inversor',         'Inversor zona C sin comunicación, producción nula',   48.0,  TRUE),
(2,  '2023-07-18', 'baja',    'Suciedad',               'Reducción de rendimiento por acumulación de polvo',    0.0,  TRUE),
(3,  '2024-01-08', 'crítica', 'Fallo mecánico',         'Fuga en circuito de sales fundidas — parada total', 120.0,  TRUE),
(3,  '2023-12-15', 'media',   'Fallo de seguimiento',   'Error en sistema de seguimiento solar sector 3',      12.0,  TRUE),
(6,  '2023-11-18', 'alta',    'Fallo mecánico',         'Ruido anómalo en rodamiento aerogenerador 4',         56.0,  TRUE),
(6,  '2024-08-03', 'media',   'Alarma eléctrica',       'Sobretensión en línea de evacuación',                  8.0,  TRUE),
(8,  '2024-05-30', 'crítica', 'Daño por rayo',          'Impacto de rayo en aerogenerador 7, daños graves',    72.0,  TRUE),
(8,  '2023-09-10', 'baja',    'Fallo comunicación',     'Pérdida de señal SCADA durante tormenta eléctrica',    2.0,  TRUE),
(11, '2023-08-22', 'media',   'Vibración excesiva',     'Desequilibrio en pala 2 del aerogenerador 3',         18.0,  TRUE),
(14, '2024-02-08', 'alta',    'Daño estructural',       'Acumulación de hielo en palas tras temporal',         96.0,  TRUE),
(15, '2023-05-14', 'baja',    'Fallo sensor',           'Sensor de temperatura defectuoso en inversor',         1.5,  TRUE),
(17, '2024-04-19', 'media',   'Fallo de red',           'Microinterrupción en punto de conexión a red',         3.0,  TRUE),
(18, '2024-09-25', 'baja',    'Fallo comunicación',     'Pérdida de telemetría en 2 aerogeneradores',           0.5,  TRUE),
(20, '2024-03-10', 'media',   'Fallo inversor',         'Inversor de nueva instalación con firmware desactualizado', 6.0, FALSE);


-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT 'provincias'        AS tabla, COUNT(*) AS registros FROM provincias
UNION ALL
SELECT 'tecnologias',                COUNT(*)               FROM tecnologias
UNION ALL
SELECT 'plantas_renovables',         COUNT(*)               FROM plantas_renovables
UNION ALL
SELECT 'produccion',                 COUNT(*)               FROM produccion
UNION ALL
SELECT 'mantenimiento',              COUNT(*)               FROM mantenimiento
UNION ALL
SELECT 'incidencias',                COUNT(*)               FROM incidencias;
