import pandas as pd
from src.conexion import get_engine

engine = get_engine()


def produccion_por_tecnologia(año=2024):
    """
    Producción total en GWh, número de plantas y media diaria
    agrupados por tecnología para el año indicado.
    """
    query = f"""
        SELECT t.nombre                                           AS tecnologia,
               COUNT(DISTINCT p.id_planta)                       AS num_plantas,
               ROUND(SUM(pr.kwh_producidos)::NUMERIC/1000000, 2) AS total_gwh,
               ROUND(AVG(pr.kwh_producidos)::NUMERIC, 0)         AS media_diaria_kwh
        FROM produccion pr
        JOIN plantas_renovables p ON pr.id_planta    = p.id_planta
        JOIN tecnologias t        ON p.id_tecnologia = t.id_tecnologia
        WHERE EXTRACT(YEAR FROM pr.fecha) = {año}
        GROUP BY t.nombre
        ORDER BY total_gwh DESC
    """
    return pd.read_sql(query, engine)


def produccion_mensual(año=2024):
    """
    Producción mensual en GWh por tecnología con acumulado progresivo.
    Útil para gráficos de líneas y análisis de estacionalidad.
    """
    query = f"""
        WITH mensual AS (
            SELECT t.nombre                                           AS tecnologia,
                   EXTRACT(MONTH FROM pr.fecha)                      AS mes,
                   ROUND(SUM(pr.kwh_producidos)::NUMERIC/1000000, 2) AS gwh_mes
            FROM produccion pr
            JOIN plantas_renovables p ON pr.id_planta    = p.id_planta
            JOIN tecnologias t        ON p.id_tecnologia = t.id_tecnologia
            WHERE EXTRACT(YEAR FROM pr.fecha) = {año}
            GROUP BY t.nombre, mes
        )
        SELECT tecnologia, mes, gwh_mes,
               SUM(gwh_mes) OVER (PARTITION BY tecnologia ORDER BY mes) AS gwh_acumulado
        FROM mensual
        ORDER BY tecnologia, mes
    """
    return pd.read_sql(query, engine)


def ranking_comunidades(año=2024):
    """
    Ranking de comunidades autónomas por producción total.
    Incluye número de plantas, potencia instalada y posición en el ranking.
    """
    query = f"""
        WITH produccion_prov AS (
            SELECT p.id_provincia,
                   ROUND(SUM(pr.kwh_producidos)::NUMERIC/1000000, 2) AS total_gwh
            FROM produccion pr
            JOIN plantas_renovables p ON pr.id_planta = p.id_planta
            WHERE EXTRACT(YEAR FROM pr.fecha) = {año}
            GROUP BY p.id_provincia
        )
        SELECT pv.comunidad,
               COUNT(DISTINCT p.id_planta)           AS num_plantas,
               ROUND(SUM(p.potencia_mw)::NUMERIC, 1) AS potencia_mw,
               pp.total_gwh,
               RANK() OVER (ORDER BY pp.total_gwh DESC) AS ranking
        FROM provincias pv
        JOIN plantas_renovables p ON pv.id_provincia = p.id_provincia
        JOIN produccion_prov pp   ON pv.id_provincia = pp.id_provincia
        GROUP BY pv.comunidad, pp.total_gwh
        ORDER BY ranking
    """
    return pd.read_sql(query, engine)


def anomalias_produccion(umbral_pct=-0.30, año=2024):
    """
    Días con caída de producción superior al umbral respecto al día anterior.
    Por defecto detecta caídas mayores al 30%.
    Útil para identificar averías o paradas no planificadas.
    """
    query = f"""
        WITH variacion AS (
            SELECT id_planta, fecha, kwh_producidos,
                   LAG(kwh_producidos) OVER (
                       PARTITION BY id_planta ORDER BY fecha
                   ) AS kwh_ayer
            FROM produccion
            WHERE EXTRACT(YEAR FROM fecha) = {año}
        )
        SELECT p.nombre AS planta,
               v.fecha,
               v.kwh_producidos,
               v.kwh_ayer,
               ROUND(
                   ((v.kwh_producidos - v.kwh_ayer) / v.kwh_ayer * 100)::NUMERIC
               , 1) AS variacion_pct
        FROM variacion v
        JOIN plantas_renovables p ON v.id_planta = p.id_planta
        WHERE v.kwh_ayer > 0
          AND (v.kwh_producidos - v.kwh_ayer) / v.kwh_ayer < {umbral_pct}
        ORDER BY variacion_pct ASC
    """
    return pd.read_sql(query, engine)


def kpis_mantenimiento():
    """
    Coste total de mantenimiento, horas de parada y número de incidencias
    por planta. Usa LEFT JOIN para incluir plantas sin incidencias (valor 0).
    """
    query = """
        WITH costes AS (
            SELECT id_planta,
                   SUM(coste_eur) AS coste_total
            FROM mantenimiento
            GROUP BY id_planta
        ),
        paradas AS (
            SELECT id_planta,
                   SUM(horas_parada) AS horas_perdidas,
                   COUNT(*)          AS num_incidencias
            FROM incidencias
            GROUP BY id_planta
        )
        SELECT p.nombre,
               t.nombre                        AS tecnologia,
               COALESCE(c.coste_total, 0)      AS coste_mantenimiento_eur,
               COALESCE(pa.horas_perdidas, 0)  AS horas_perdidas,
               COALESCE(pa.num_incidencias, 0) AS num_incidencias
        FROM plantas_renovables p
        JOIN tecnologias t   ON p.id_tecnologia = t.id_tecnologia
        LEFT JOIN costes c   ON p.id_planta     = c.id_planta
        LEFT JOIN paradas pa ON p.id_planta     = pa.id_planta
        ORDER BY coste_mantenimiento_eur DESC
    """
    return pd.read_sql(query, engine)