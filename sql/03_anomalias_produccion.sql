-- ============================================================
-- Consulta 03: Detección de anomalías de producción
-- ============================================================
-- Objetivo: identificar días con caída de producción superior
-- al 30% respecto al día anterior por planta. Útil para
-- detectar averías o paradas no planificadas.
--
-- Técnicas: CTE, window function LAG(), cálculo de variación
--           porcentual, filtrado con HAVING implícito en WHERE
-- ============================================================

WITH variacion AS (
    SELECT id_planta,
           fecha,
           kwh_producidos,
           LAG(kwh_producidos) OVER (
               PARTITION BY id_planta
               ORDER BY fecha
           ) AS kwh_dia_anterior
    FROM produccion
    WHERE EXTRACT(YEAR FROM fecha) = 2024
)
SELECT p.nombre AS planta,
       v.fecha,
       v.kwh_producidos,
       v.kwh_dia_anterior,
       ROUND(
           ((v.kwh_producidos - v.kwh_dia_anterior) / v.kwh_dia_anterior * 100)::NUMERIC
       , 1) AS variacion_pct
FROM variacion v
JOIN plantas_renovables p ON v.id_planta = p.id_planta
WHERE v.kwh_dia_anterior > 0
  AND (v.kwh_producidos - v.kwh_dia_anterior) / v.kwh_dia_anterior < -0.30
ORDER BY variacion_pct ASC;