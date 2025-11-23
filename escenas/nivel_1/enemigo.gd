extends CharacterBody2D

@export var speed := 80
@onready var anim := $AnimatedSprite2D
@onready var detection_area := $Area2D

var player: CharacterBody2D
var follow_player := false

func _ready():
	detection_area.body_entered.connect(_on_area_2d_body_entered)
	detection_area.body_exited.connect(_on_area_2d_body_exited)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if follow_player and player:
		# Dirección hacia el jugador
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# Flip según la dirección X (sprite mira a la derecha por defecto)
		anim.flip_h = dir.x < 0
		anim.play("walk")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		anim.play("idle")

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		follow_player = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		follow_player = false
 
