# SQL Renewables Analytics

Proyecto de análisis de datos aplicado al sector de energías renovables en España.
Combina PostgreSQL, Python y Streamlit para construir un pipeline completo
desde la base de datos hasta un dashboard interactivo.

---

## Tecnologías utilizadas

- **PostgreSQL 18** — base de datos relacional
- **Python 3.13** — análisis y visualización de datos
- **pandas** — manipulación de DataFrames
- **SQLAlchemy** — conexión Python ↔ PostgreSQL
- **Plotly** — gráficos interactivos
- **Streamlit** — dashboard web
- **python-dotenv** — gestión de credenciales

---

## Estructura del proyecto
```
sql-renewables-analytics/
├── data/
│   └── energia_renovable_dataset.sql   # Dataset con 6 tablas y ~13.000 registros
├── sql/
│   ├── 01_produccion_por_tecnologia.sql
│   ├── 02_ranking_comunidades.sql
│   ├── 03_anomalias_produccion.sql
│   ├── 04_eficiencia_plantas.sql
│   └── 05_kpis_mantenimiento.sql
├── src/
│   ├── conexion.py      # Módulo de conexión centralizado
│   ├── kpis.py          # Consultas SQL como funciones Python
│   └── graficos.py      # Gráficos Plotly
├── dashboard/
│   └── app.py           # Aplicación Streamlit
├── notebooks/
│   └── analisis_exploratorio.ipynb
├── .env                 # Credenciales (no incluido en el repositorio)
├── .gitignore
├── pyproject.toml
├── requirements.txt
└── README.md
```

---

## Dataset

Base de datos ficticia pero realista del sector renovable español con 6 tablas:

| Tabla | Registros | Descripción |
|---|---|---|
| `provincias` | 10 | Provincias con horas de sol anuales |
| `tecnologias` | 8 | Tipos de tecnología y madurez |
| `plantas_renovables` | 20 | Plantas con potencia, ubicación e inversión |
| `produccion` | ~13.000 | kWh diarios por planta (2023-2024) |
| `mantenimiento` | 15 | Trabajos preventivos y correctivos |
| `incidencias` | 15 | Averías con severidad y horas de parada |

---

## Instalación y uso

### Requisitos previos

- PostgreSQL 18 instalado y corriendo
- Python 3.10 o superior
- Base de datos `energia_renovable` creada en PostgreSQL

### Pasos

**1. Clonar el repositorio:**
```bash
git clone https://github.com/tu_usuario/sql-renewables-analytics.git
cd sql-renewables-analytics
```

**2. Crear y activar el entorno virtual:**
```bash
python3 -m venv venv
source venv/bin/activate        # Linux / macOS
venv\Scripts\activate           # Windows
```

**3. Instalar dependencias:**
```bash
pip install -r requirements.txt
pip install -e .
```

**4. Configurar credenciales:**

Crea un archivo `.env` en la raíz con tus datos de conexión:
```
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
DB_HOST=localhost
DB_PORT=5432
DB_NAME=energia_renovable
```

**5. Cargar el dataset en PostgreSQL:**
```bash
psql -U tu_usuario -d energia_renovable -h localhost -f data/energia_renovable_dataset.sql
```

**6. Lanzar el dashboard:**
```bash
streamlit run dashboard/app.py
```

Abre el navegador en `http://localhost:8501`.

---

## Consultas SQL destacadas

El proyecto incluye 5 consultas SQL avanzadas documentadas en la carpeta `sql/`:

- Producción por tecnología con GROUP BY y funciones de agregación
- Ranking de comunidades con window function RANK()
- Detección de anomalías con window function LAG()
- Eficiencia por planta (kWh por MW instalado)
- KPIs de mantenimiento con CTEs encadenadas

---

## Autor

**Juan Jaramillo** — Ingeniero Industrial  
Curso de SQL con PostgreSQL · 2026