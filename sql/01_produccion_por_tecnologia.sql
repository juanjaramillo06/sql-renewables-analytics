-- ============================================================
-- Consulta 01: Producción total por tecnología
-- ============================================================
-- Objetivo: comparar el rendimiento de cada tecnología renovable
-- durante el año 2024, calculando producción total, media diaria
-- y número de plantas activas por tipo.
--
-- Técnicas: JOIN múltiple, GROUP BY, funciones de agregación,
--           conversión de unidades (kWh → GWh)
-- ============================================================

SELECT t.nombre                                           AS tecnologia,
       COUNT(DISTINCT p.id_planta)                        AS num_plantas,
       ROUND(SUM(pr.kwh_producidos)::NUMERIC / 1000000, 2) AS total_gwh,
       ROUND(AVG(pr.kwh_producidos)::NUMERIC, 0)          AS media_diaria_kwh,
       ROUND(MAX(pr.kwh_producidos)::NUMERIC, 0)          AS pico_maximo_kwh
FROM produccion pr
JOIN plantas_renovables p ON pr.id_planta    = p.id_planta
JOIN tecnologias t         ON p.id_tecnologia = t.id_tecnologia
WHERE EXTRACT(YEAR FROM pr.fecha) = 2024
GROUP BY t.nombre
ORDER BY total_gwh DESC;