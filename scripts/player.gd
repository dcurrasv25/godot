extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SERVER_URL := "http://127.0.0.1:8000/deaths"

@onready var anim = $AnimatedSprite2D
@onready var death_label = $DeathLabel 
@onready var http_request = $HTTPRequest # ¡Asegúrate de añadir este nodo al Player!

var start_position : Vector2
var death_count := 0

func _ready():
	add_to_group("player")
	start_position = global_position
	update_label()
	
	# Conectamos la señal para saber cuando el servidor responde
	if http_request:
		http_request.request_completed.connect(_on_request_completed)

func die():
	# 1. Lógica local
	death_count += 1
	update_label()
	print("Muerte #", death_count)
	
	# 2. ENVIAR AL SERVIDOR
	send_deaths_to_server()
	
	# 3. Respawn
	global_position = start_position

func send_deaths_to_server():
	if not http_request:
		print("Error: Falta el nodo HTTPRequest en el Jugador")
		return

	# Evitamos errores si ya hay una petición en curso
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return 

	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"deaths": death_count})
	
	var error = http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Error al intentar enviar muertes al servidor")

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Servidor confirmó recepción de muerte.")
	else:
		print("Error en servidor al enviar muerte: ", response_code)

func update_label():
	if death_label:
		death_label.text = "Muertes: " + str(death_count)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim.play("Correr")
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim.play("idle")

	if not is_on_floor():
		anim.play("Salto")

	move_and_slide()
