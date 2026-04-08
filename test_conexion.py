from src.conexion import get_engine
import pandas as pd

engine = get_engine()
df = pd.read_sql("SELECT COUNT(*) AS total FROM plantas_renovables", engine)
print(df)