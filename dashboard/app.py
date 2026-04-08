import streamlit as st
from src.graficos import (grafico_produccion_tecnologia, grafico_produccion_mensual,
                           grafico_ranking_comunidades, grafico_anomalias,
                           grafico_mantenimiento)
from src.kpis import produccion_por_tecnologia, kpis_mantenimiento

# ── Configuración de la página ────────────────────────────────
# Debe ser siempre el primer comando de Streamlit en el script
st.set_page_config(
    page_title='Renewables Analytics',
    layout='wide',        # usa todo el ancho de la pantalla
    page_icon='⚡'
)

# ── Cabecera ──────────────────────────────────────────────────
st.title('Dashboard — Análisis operacional de plantas renovables')
st.caption('Dataset ficticio · España · 2023-2024 · PostgreSQL + Python + Streamlit')

# ── Selector de año en la barra lateral ───────────────────────
# st.sidebar coloca elementos en el panel lateral izquierdo
año = st.sidebar.selectbox('Año', [2024, 2023], index=0)
st.sidebar.markdown('---')
st.sidebar.markdown('**Proyecto:** sql-renewables-analytics')
st.sidebar.markdown('**Autor:** Juan Jaramillo')

# ── KPIs resumen (métricas destacadas) ───────────────────────
# st.columns divide la fila en columnas de igual ancho
st.subheader(f'Resumen {año}')
df_tec = produccion_por_tecnologia(año)
total_gwh     = df_tec['total_gwh'].sum()
total_plantas = int(df_tec['num_plantas'].sum())
mejor_tec     = df_tec.iloc[0]['tecnologia']
num_tec       = len(df_tec)

col1, col2, col3, col4 = st.columns(4)
col1.metric('Producción total',  f'{total_gwh:,.0f} GWh')
col2.metric('Plantas activas',   f'{total_plantas}')
col3.metric('Tecnologías',       f'{num_tec}')
col4.metric('Mayor productora',  mejor_tec)

st.divider()

# ── Fila 1: producción por tecnología y mensual ───────────────
col_a, col_b = st.columns(2)
with col_a:
    st.plotly_chart(grafico_produccion_tecnologia(año), use_container_width=True)
with col_b:
    st.plotly_chart(grafico_produccion_mensual(año), use_container_width=True)

# ── Fila 2: ranking comunidades y anomalías ───────────────────
col_c, col_d = st.columns(2)
with col_c:
    st.plotly_chart(grafico_ranking_comunidades(año), use_container_width=True)
with col_d:
    st.plotly_chart(grafico_anomalias(año), use_container_width=True)

# ── Fila 3: mantenimiento (ancho completo) ────────────────────
st.plotly_chart(grafico_mantenimiento(), use_container_width=True)

# ── Tabla de datos detallada ──────────────────────────────────
st.subheader('Detalle por planta — mantenimiento e incidencias')
st.dataframe(kpis_mantenimiento(), use_container_width=True)