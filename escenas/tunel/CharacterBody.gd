extends CharacterBody3D

@export var speed := 5.0
@export var mouse_sensitivity := 0.1
var yaw := 0.0
var pitch := 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -90, 90)
		rotation_degrees.y = yaw
		$Camera3D.rotation_degrees.x = pitch

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
