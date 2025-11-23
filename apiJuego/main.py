from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI()

# Modelo para recibir datos en el POST
class CoinUpdate(BaseModel):
    coins: int

coins_collected = 0

# 1. Ruta Raíz (Para que no salga 404 en el navegador)
@app.get("/")
def index():
    return {"mensaje": "Servidor de Godot activo", "monedas": coins_collected}

# 2. Obtener items (GET)
@app.get("/items")
def get_items():
    return {"count": coins_collected}

# 3. Guardar items (POST)
@app.post("/items")
def add_item(item: CoinUpdate):
    global coins_collected
    coins_collected = item.coins
    print(f"Recibido desde Godot: {item.coins}")
    return {"count": coins_collected}

@app.get("/favicon.ico")
def favicon():
    return JSONResponse(content={}, status_code=204)