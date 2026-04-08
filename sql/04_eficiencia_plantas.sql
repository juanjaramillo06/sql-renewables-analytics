-- ============================================================
-- Consulta 04: Eficiencia de plantas (kWh por MW instalado)
-- ============================================================
-- Objetivo: calcular qué plantas generan más energía por cada
-- MW de potencia instalada — indicador real de eficiencia
-- operacional independiente del tamaño de la planta.
--
-- Técnicas: CTE encadenadas, JOIN múltiple, window function
--           RANK(), división para calcular ratio de eficiencia
-- ============================================================

WITH produccion_total AS (
    SELECT id_planta,
           ROUND(SUM(kwh_producidos)::NUMERIC / 1000000, 2) AS total_gwh
    FROM produccion
    WHERE EXTRACT(YEAR FROM fecha) = 2024
    GROUP BY id_planta
),
eficiencia AS (
    SELECT p.id_planta,
           p.nombre,
           p.potencia_mw,
           pt.total_gwh,
           ROUND((pt.total_gwh / p.potencia_mw * 1000)::NUMERIC, 1) AS kwh_por_kw_instalado
    FROM plantas_renovables p
    JOIN produccion_total pt ON p.id_planta = pt.id_planta
)
SELECT e.nombre,
       t.nombre                  AS tecnologia,
       pv.comunidad,
       e.potencia_mw,
       e.total_gwh,
       e.kwh_por_kw_instalado,
       RANK() OVER (ORDER BY e.kwh_por_kw_instalado DESC) AS ranking_eficiencia
FROM eficiencia e
JOIN plantas_renovables p ON e.id_planta    = p.id_planta
JOIN tecnologias t         ON p.id_tecnologia = t.id_tecnologia
JOIN provincias pv         ON p.id_provincia  = pv.id_provincia
ORDER BY ranking_eficiencia;