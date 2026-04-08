-- ============================================================
-- Consulta 02: Ranking de comunidades autónomas
-- ============================================================
-- Objetivo: clasificar las comunidades autónomas por producción
-- total en 2024, mostrando potencia instalada y número de plantas.
--
-- Técnicas: CTE, JOIN múltiple, GROUP BY, window function RANK()
-- ============================================================

WITH produccion_prov AS (
    SELECT p.id_provincia,
           ROUND(SUM(pr.kwh_producidos)::NUMERIC / 1000000, 2) AS total_gwh
    FROM produccion pr
    JOIN plantas_renovables p ON pr.id_planta = p.id_planta
    WHERE EXTRACT(YEAR FROM pr.fecha) = 2024
    GROUP BY p.id_provincia
)
SELECT pv.comunidad,
       COUNT(DISTINCT p.id_planta)            AS num_plantas,
       ROUND(SUM(p.potencia_mw)::NUMERIC, 1)  AS potencia_instalada_mw,
       pp.total_gwh,
       RANK() OVER (ORDER BY pp.total_gwh DESC) AS ranking
FROM provincias pv
JOIN plantas_renovables p ON pv.id_provincia = p.id_provincia
JOIN produccion_prov pp   ON pv.id_provincia = pp.id_provincia
GROUP BY pv.comunidad, pp.total_gwh
ORDER BY ranking;