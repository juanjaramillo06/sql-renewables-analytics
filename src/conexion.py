import os
from sqlalchemy import create_engine
from dotenv import load_dotenv

# Carga las variables del archivo .env al entorno del proceso
load_dotenv()

def get_engine():
    """
    Devuelve un engine de SQLAlchemy conectado a PostgreSQL.
    Las credenciales se leen del archivo .env — nunca están en el código.
    """
    return create_engine(
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )