extends Area3D

# Esta variable te permite elegir la escena desde el Inspector de Godot
# sin tener que tocar el código si cambias el nombre del archivo.
@export_file("*.tscn") var siguiente_escena_path: String

func _ready() -> void:
	# Conectamos la señal dinámicamente para asegurar que no falla
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Verificamos si lo que entró es el Jugador.
	# Hay dos formas seguras de hacerlo:
	
	# OPCIÓN A: Comprobar si es un CharacterBody3D (Si solo el jugador usa este tipo)
	if body is CharacterBody3D:
		cambiar_nivel()
		
	# OPCIÓN B (Más segura): Comprobar si está en el grupo "player"
	# (Para esto, asegúrate de añadir: add_to_group("player") en el _ready del jugador)
	# if body.is_in_group("player"):
	#    cambiar_nivel()

func cambiar_nivel() -> void:
	print("Jugador detectado. Cargando: ", siguiente_escena_path)
	
	if siguiente_escena_path == "":
		print("ERROR: No has asignado la escena en el Inspector del Area3D")
		return

	# Usamos call_deferred. Es VITAL en Godot cambiar escenas fuera del 
	# cálculo de físicas para evitar errores o cierres inesperados.
	call_deferred("_cambio_seguro")

func _cambio_seguro() -> void:
	get_tree().change_scene_to_file(siguiente_escena_path)
