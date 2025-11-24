extends Area2D

func _ready() -> void:
	# Conectamos la señal por código para asegurar que funcione, 
	# o puedes hacerlo desde el editor.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si es el jugador
	if body.is_in_group("player"):
		# Verificamos si el jugador tiene la función para recoger el item
		if body.has_method("add_attack_ammo"):
			body.add_attack_ammo(1) # Le damos 1 carga
			queue_free() # El item desaparece
