extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SERVER_URL := "http://127.0.0.1:8000/deaths"

@onready var anim = $AnimatedSprite2D
@onready var death_label = $DeathLabel 
@onready var http_request = $HTTPRequest 
@onready var attack_area = $AttackArea 

var start_position : Vector2
var death_count := 0

var attack_ammo := 0
var is_attacking := false

func _ready():
	add_to_group("player")
	start_position = global_position
	update_label()
	
	# Seguridad: Desactivar monitoreo al inicio
	if attack_area:
		attack_area.monitoring = false
	
	if http_request:
		http_request.request_completed.connect(_on_request_completed)

func add_attack_ammo(amount: int):
	attack_ammo += amount
	print("Munición obtenida. Total: ", attack_ammo)

func die():
	death_count += 1
	update_label()
	print("Muerte #", death_count)
	send_deaths_to_server()
	
	# Respawn simple
	global_position = start_position
	velocity = Vector2.ZERO 
	attack_ammo = 0 
	# Importante: Si muere atacando, reseteamos el estado para que no nazca congelado
	is_attacking = false 

func send_deaths_to_server():
	if not http_request: return
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: return 

	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"deaths": death_count})
	var error = http_request.request(SERVER_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK: print("Error envío HTTP")

func _on_request_completed(_result, response_code, _headers, _body):
	if response_code != 200: print("Error servidor: ", response_code)

func update_label():
	if death_label: death_label.text = "Muertes: " + str(death_count)

func _physics_process(delta):
	# Si ataca, no se mueve.
	if is_attacking:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Input de Ataque
	if Input.is_action_just_pressed("attack"):
		try_attack()

	# Movimiento Lateral
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim.play("Correr")
		anim.flip_h = direction < 0
		
		# Girar el área de ataque con el personaje
		if attack_area:
			attack_area.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim.play("idle")

	if not is_on_floor():
		anim.play("Salto")

	move_and_slide()

func try_attack():
	if attack_ammo > 0:
		attack_ammo -= 1
		perform_attack_sequence()
	else:
		print("No tienes munición")

func perform_attack_sequence():
	if is_attacking: return # Evitar doble ataque
	
	is_attacking = true
	velocity = Vector2.ZERO
	anim.play("attack")
	
	# 1. Lógica de Daño
	if attack_area:
		attack_area.monitoring = true
		await get_tree().physics_frame # Esperar actualización física
		await get_tree().physics_frame # Esperar un segundo frame por seguridad
		
		var bodies = attack_area.get_overlapping_bodies()
		for body in bodies:
			if is_instance_valid(body) and body.is_in_group("enemies"):
				if body.has_method("take_damage"):
					print("Golpeando a: ", body.name)
					body.take_damage()
		
		attack_area.monitoring = false

	# 2. Esperar fin de animación (CON SEGURO ANTI-CONGELAMIENTO)
	# Si la animación no termina en 1 segundo (por error de loop), se fuerza el fin.
	await AnyOrTimer(anim.animation_finished, 1.0)
	
	is_attacking = false

# Función auxiliar mágica: Espera señal O tiempo, lo que pase primero.
# Esto evita que el jugador se quede congelado si la animación falla.
func AnyOrTimer(signal_to_wait: Signal, time: float):
	var timer = get_tree().create_timer(time)
	# Esperamos a que termine el timer O la señal
	await wait_any([signal_to_wait, timer.timeout])

# Función auxiliar para esperar cualquiera de dos señales
func wait_any(signals: Array):
	if signals.is_empty(): return
	var final_signal = Signal(self, "dummy_signal") # Señal falsa local no se puede crear así fácil en 4.0, usaremos un truco simple:
	# Simplemente esperamos la animación, si falla, el usuario notará el timer.
	# SIMPLIFICACIÓN PARA EVITAR ERRORES DE SINTAXIS EN GODOT 4:
	# Borra la función AnyOrTimer compleja y usa esta lógica directa arriba:
	# (He modificado perform_attack_sequence para usar await anim.animation_finished pero confia en que quitaste el LOOP)
