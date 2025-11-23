extends CharacterBody2D

@export var speed := 80
@onready var anim := $AnimatedSprite2D
@onready var detection_area := $Area2D

var player: CharacterBody2D = null
var follow_player := false
var is_attacking := false 

func _ready():
	if detection_area:
		# Conectamos las señales de visión
		detection_area.body_entered.connect(_on_area_2d_body_entered)
		detection_area.body_exited.connect(_on_area_2d_body_exited)

func _physics_process(delta):
	# Si está atacando, no se mueve ni hace nada más hasta acabar
	if is_attacking:
		return

	# Si tenemos objetivo y existe en el mundo
	if follow_player and player != null:
		# 1. PERSEGUIR
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# 2. ANIMACIÓN Y GIRO
		if dir.x != 0:
			anim.flip_h = dir.x > 0
		anim.play("walk")
		
		# 3. VERIFICAR ATAQUE
		check_attack_range()
				
	else:
		# Si no hay jugador o se escapó
		velocity = Vector2.ZERO
		move_and_slide()
		anim.play("idle")

func check_attack_range():
	# Verifica colisiones físicas
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		# Si tocamos al jugador, atacamos
		if body.is_in_group("player"):
			start_attack(body)
			return # Importante: salir para no atacar dos veces en el mismo frame

func start_attack(target):
	# Bloqueamos al enemigo
	is_attacking = true 
	velocity = Vector2.ZERO # Frenar en seco
	
	anim.play("attack")
	
	# Matamos al jugador inmediatamente
	if target.has_method("die"):
		target.die()

	# --- ESPERAS Y COOLDOWN (SOLUCIÓN DEL BLOQUEO) ---
	
	# 1. Esperamos que termine la animación visual
	await anim.animation_finished
	
	# 2. (Opcional) Agregamos un pequeño tiempo extra (0.5s) para que no ataque a la velocidad de la luz
	# Esto crea el temporizador por código, sin nodos extra.
	await get_tree().create_timer(0.5).timeout
	
	# Desbloqueamos al enemigo. Ahora está listo para perseguir o matar de nuevo.
	is_attacking = false 

# --- SISTEMA DE VISIÓN ---

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		follow_player = true

func _on_area_2d_body_exited(body):
	if body == player:
		follow_player = false
		player = null
		# Si el jugador huye o muere y sale del área, nos aseguramos 
		# de que el enemigo no se quede "bugueado" intentando atacar al aire.
