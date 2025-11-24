extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var follow_player=false
var player =null
var speed := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if follow_player:
		var dir = (player.global_position - global_position).normalized()
		
		if dir.x > 0: 
			animated_sprite_2d.flip_h=false
		elif dir.x < 0 :
			animated_sprite_2d.flip_h=true
		velocity = dir * speed
		move_and_slide()




func _on_area_2d_body_entered(body: Node2D) -> void:
	player=body
	follow_player=true


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	queue_free()
