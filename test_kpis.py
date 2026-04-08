from src.kpis import (produccion_por_tecnologia, produccion_mensual,
                      ranking_comunidades, anomalias_produccion, kpis_mantenimiento)

print("=== Producción por tecnología ===")
print(produccion_por_tecnologia())

print("\n=== Ranking comunidades ===")
print(ranking_comunidades())

print("\n=== KPIs mantenimiento ===")
print(kpis_mantenimiento())