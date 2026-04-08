-- ============================================================
-- Consulta 05: KPIs de mantenimiento e incidencias por planta
-- ============================================================
-- Objetivo: consolidar en una sola vista el coste total de
-- mantenimiento, horas perdidas por incidencias y número de
-- eventos por planta. Útil para priorizar inversiones en
-- mantenimiento preventivo.
--
-- Técnicas: CTEs encadenadas, LEFT JOIN para incluir plantas
--           sin incidencias, COALESCE para tratar NULLs
-- ============================================================

WITH costes AS (
    SELECT id_planta,
           COUNT(*)          AS num_mantenimientos,
           SUM(coste_eur)    AS coste_total_eur
    FROM mantenimiento
    GROUP BY id_planta
),
paradas AS (
    SELECT id_planta,
           COUNT(*)            AS num_incidencias,
           SUM(horas_parada)   AS horas_perdidas_total,
           COUNT(*) FILTER (WHERE severidad = 'crítica') AS incidencias_criticas
    FROM incidencias
    GROUP BY id_planta
)
SELECT p.nombre,
       t.nombre                              AS tecnologia,
       pv.comunidad,
       COALESCE(c.num_mantenimientos, 0)     AS num_mantenimientos,
       COALESCE(c.coste_total_eur, 0)        AS coste_mantenimiento_eur,
       COALESCE(pa.num_incidencias, 0)       AS num_incidencias,
       COALESCE(pa.horas_perdidas_total, 0)  AS horas_perdidas,
       COALESCE(pa.incidencias_criticas, 0)  AS incidencias_criticas
FROM plantas_renovables p
JOIN tecnologias t    ON p.id_tecnologia = t.id_tecnologia
JOIN provincias pv    ON p.id_provincia  = pv.id_provincia
LEFT JOIN costes c    ON p.id_planta     = c.id_planta
LEFT JOIN paradas pa  ON p.id_planta     = pa.id_planta
ORDER BY coste_mantenimiento_eur DESC;