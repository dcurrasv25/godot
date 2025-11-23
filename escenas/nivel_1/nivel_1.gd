extends Node2D

@onready var label: Label = $Player/Camera2D/Label
@onready var http: HTTPRequest = $HTTPRequest

var coins := 0
const SERVER_URL := "http://127.0.0.1:8000/items"

func _ready():
	http.request_completed.connect(_on_request_completed) # Sintaxis recomendada Godot 4
	# Nota: request() devuelve un Error, es bueno comprobarlo
	var error = http.request(SERVER_URL, [], HTTPClient.METHOD_GET)
	if error != OK:
		print("Error al hacer petición GET inicial")

func addcoin():
	# IMPORTANTE: Si el nodo HTTP está ocupado, dará error.
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return # O poner en cola, pero por ahora evitamos el crash

	coins += 1
	label.text = str(coins)

	var body := JSON.stringify({"coins": coins}) # No hace falta .to_utf8_buffer() aquí, request lo maneja, pero no está mal dejarlo.
	var headers := PackedStringArray(["Content-Type: application/json"])
	
	http.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error Servidor: ", response_code)
		return
	
	# --- AQUÍ ESTABA EL ERROR PRINCIPAL ---
	var json_response = JSON.parse_string(body.get_string_from_utf8())
	
	# En Godot 4 verificamos si es null o si es un Diccionario válido
	if json_response and json_response is Dictionary:
		if "count" in json_response:
			coins = json_response["count"]
			label.text = str(coins)
			print("Monedas actualizadas desde servidor: ", coins)
	else:
		print("Error al leer JSON")
