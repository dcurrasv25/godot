extends Area2D

@onready var nivel_1 = get_parent()

func _on_body_entered(body):
	if body.is_in_group("player"):
		nivel_1.addcoin()
		queue_free()
