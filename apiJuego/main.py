from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI()

# --- MODELOS ---
class CoinUpdate(BaseModel):
    coins: int

class DeathUpdate(BaseModel):
    deaths: int

# --- VARIABLES ---
coins_collected = 0
total_deaths = 0

@app.get("/")
def index():
    return {"mensaje": "Servidor activo", "monedas": coins_collected, "muertes": total_deaths}

# --- ENDPOINTS MONEDAS ---
@app.get("/items")
def get_items():
    return {"count": coins_collected}

@app.post("/items")
def add_item(item: CoinUpdate):
    global coins_collected
    coins_collected = item.coins
    print(f"Monedas recibidas: {item.coins}")
    return {"count": coins_collected}

# --- ENDPOINTS MUERTES (NUEVO) ---
@app.post("/deaths")
def update_deaths(data: DeathUpdate):
    global total_deaths
    total_deaths = data.deaths
    print(f"Muertes recibidas desde Godot: {total_deaths}")
    return {"status": "ok", "total_deaths": total_deaths}

@app.get("/favicon.ico")
def favicon():
    return JSONResponse(content={}, status_code=204)