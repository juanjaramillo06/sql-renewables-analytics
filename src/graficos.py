import plotly.express as px
from src.kpis import (produccion_por_tecnologia, produccion_mensual,
                      ranking_comunidades, anomalias_produccion,
                      kpis_mantenimiento)


def grafico_produccion_tecnologia(año=2024):
    """
    Gráfico de barras: producción total en GWh por tecnología.
    Cada barra tiene un color distinto por tecnología.
    """
    df = produccion_por_tecnologia(año)
    fig = px.bar(
        df,
        x='tecnologia',
        y='total_gwh',
        color='tecnologia',
        title=f'Producción total por tecnología — {año}',
        labels={'total_gwh': 'GWh producidos', 'tecnologia': 'Tecnología'},
        color_discrete_sequence=px.colors.qualitative.Safe
    )
    fig.update_layout(showlegend=False)
    return fig


def grafico_produccion_mensual(año=2024):
    """
    Gráfico de líneas: evolución mensual de producción por tecnología.
    Muestra la estacionalidad — solar produce más en verano, eólica en invierno.
    """
    df = produccion_mensual(año)
    fig = px.line(
        df,
        x='mes',
        y='gwh_mes',
        color='tecnologia',
        markers=True,
        title=f'Producción mensual por tecnología — {año}',
        labels={'gwh_mes': 'GWh', 'mes': 'Mes', 'tecnologia': 'Tecnología'}
    )
    fig.update_xaxes(
        tickvals=list(range(1, 13)),
        ticktext=['Ene','Feb','Mar','Abr','May','Jun',
                  'Jul','Ago','Sep','Oct','Nov','Dic']
    )
    return fig


def grafico_ranking_comunidades(año=2024):
    """
    Gráfico de barras horizontales: comunidades ordenadas por producción total.
    El color indica la magnitud — más oscuro significa más producción.
    """
    df = ranking_comunidades(año)
    fig = px.bar(
        df,
        x='total_gwh',
        y='comunidad',
        orientation='h',
        title=f'Ranking de comunidades por producción — {año}',
        labels={'total_gwh': 'GWh producidos', 'comunidad': 'Comunidad autónoma'},
        color='total_gwh',
        color_continuous_scale='Teal'
    )
    fig.update_layout(yaxis={'categoryorder': 'total ascending'})
    return fig


def grafico_anomalias(año=2024):
    """
    Gráfico de dispersión: días con caída de producción mayor al 30%.
    Cada punto es un día anómalo. El color identifica la planta afectada.
    La línea roja marca el umbral del 30%.
    """
    df = anomalias_produccion(año=año)
    fig = px.scatter(
        df,
        x='fecha',
        y='variacion_pct',
        color='planta',
        title=f'Anomalías de producción — caídas > 30% respecto al día anterior ({año})',
        labels={'variacion_pct': 'Variación (%)', 'fecha': 'Fecha', 'planta': 'Planta'},
        hover_data=['kwh_producidos', 'kwh_ayer']
    )
    fig.add_hline(y=-30, line_dash='dash', line_color='red', opacity=0.5,
                  annotation_text='Umbral -30%')
    return fig


def grafico_mantenimiento():
    """
    Gráfico de dispersión: coste de mantenimiento vs horas de parada por planta.
    El tamaño del punto indica el número de incidencias.
    Al pasar el ratón por encima se ve el nombre de la planta.
    """
    df = kpis_mantenimiento()
    fig = px.scatter(
        df,
        x='coste_mantenimiento_eur',
        y='horas_perdidas',
        size='num_incidencias',
        color='tecnologia',
        hover_name='nombre',
        title='Coste de mantenimiento vs horas de parada por planta',
        labels={
            'coste_mantenimiento_eur': 'Coste mantenimiento (€)',
            'horas_perdidas': 'Horas de parada',
            'tecnologia': 'Tecnología'
        }
    )
    return fig