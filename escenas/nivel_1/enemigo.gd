extends CharacterBody2D

@export var speed := 80
@onready var anim := $AnimatedSprite2D
@onready var detection_area := $Area2D

var player: CharacterBody2D = null
var follow_player := false
var is_attacking := false 
var is_dead := false 

func _ready():
	add_to_group("enemies") 
	
	if detection_area:
		if not detection_area.body_entered.is_connected(_on_area_2d_body_entered):
			detection_area.body_entered.connect(_on_area_2d_body_entered)
		if not detection_area.body_exited.is_connected(_on_area_2d_body_exited):
			detection_area.body_exited.connect(_on_area_2d_body_exited)

func _physics_process(_delta):
	# Si está muerto, salir INMEDIATAMENTE
	if is_dead: return
	if is_attacking: return

	# Chequeo exhaustivo de validez
	if follow_player and is_instance_valid(player):
		var dir = (player.global_position - global_position).normalized() 
		velocity = dir * speed
		move_and_slide()

		if dir.x != 0:
			anim.flip_h = dir.x > 0
		anim.play("walk")
		
		check_attack_range()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		anim.play("idle")

func check_attack_range():
	if is_dead: return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if is_instance_valid(body) and body.is_in_group("player"):
			start_attack(body)
			return

func start_attack(target):
	if is_dead: return
	is_attacking = true 
	velocity = Vector2.ZERO 
	anim.play("attack")
	
	if is_instance_valid(target) and target.has_method("die"):
		target.die()

	await anim.animation_finished
	
	# Espera cooldown
	if not is_dead:
		await get_tree().create_timer(0.5).timeout
		is_attacking = false 

func take_damage():
	if is_dead: return
	is_dead = true # Bloqueo maestro
	
	print("Enemigo muriendo...")

	# 1. Detener todo
	velocity = Vector2.ZERO
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. Desconectar señales manualmente para evitar errores
	if detection_area:
		if detection_area.body_entered.is_connected(_on_area_2d_body_entered):
			detection_area.body_entered.disconnect(_on_area_2d_body_entered)
		if detection_area.body_exited.is_connected(_on_area_2d_body_exited):
			detection_area.body_exited.disconnect(_on_area_2d_body_exited)
	
	# 3. Borrar referencias
	player = null
	follow_player = false
	
	# 4. Adios
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		follow_player = true

func _on_area_2d_body_exited(body):
	if body == player:
		follow_player = false
		player = null
