extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cuello: Node3D = $Cuello
@onready var camera: Camera3D = $Cuello/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		cuello.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Saltar
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Dirección de movimiento
	var input_dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_dir.z += 1
	if Input.is_action_pressed("backen"):
		input_dir.z -= 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1

	# Movimiento relativo a la cámara
	var forward: Vector3 = -cuello.transform.basis.z
	var right: Vector3 = cuello.transform.basis.x
	var direction: Vector3 = (forward * input_dir.z + right * input_dir.x).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

# 🚀 LÓGICA PARA CAMBIO DE ESCENA 🚀

## Función Conectada al Area3D ("FinDeTunel")

# ESTA FUNCIÓN DEBE SER CONECTADA MANUALMENTE DESDE EL NODO FinDeTunel (Area3D)
# Selecciona el Area3D > Pestaña Nodo > Señal 'body_entered' > Conectar al nodo CharacterBody3D
func _on_fin_de_tunel_body_entered(body: Node3D) -> void:
	# Comprobamos que el cuerpo que entró en el área es ESTE personaje (el jugador).
	if body == self:
		
		# **¡IMPORTANTE!** Reemplaza esta ruta con el path real de tu siguiente escena.
		var siguiente_escena_path = "res://escenas/nivel_1/Nivel1.tscn" 
		
		print("¡El jugador ha llegado al final del túnel! Cambiando a: " + siguiente_escena_path)
		
		# Comando para cambiar de escena
		get_tree().change_scene_to_file(siguiente_escena_path)
