extends CharacterBody2D

@export var speed: float = 80
var player: Node2D
var can_chase := false

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_DetectArea_body_entered(body):
	if body.is_in_group("player"):
		can_chase = true

func _on_DetectArea_body_exited(body):
	if body.is_in_group("player"):
		can_chase = false

func _physics_process(delta):
	if can_chase and player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
