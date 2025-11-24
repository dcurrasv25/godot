extends Control

# Ruta al primer nivel que quieres cargar (tu escena del túnel 3D)
const NIVEL_INICIO_PATH = "res://escenas/tunel/tunel.tscn"
# **¡IMPORTANTE!** Reemplaza la ruta de arriba con la ruta real de tu escena del túnel.

func _ready() -> void:
	# Asegúrate de que el ratón está visible para que el usuario pueda hacer clic
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --- Funciones de Conexión de Botones ---

func _on_jugar_button_pressed() -> void:
	print("Iniciando juego...")
	# Usamos call_deferred para evitar errores al cambiar de escena inmediatamente
	call_deferred("cambiar_escena")

func _on_salir_button_pressed() -> void:
	print("Saliendo del juego...")
	get_tree().quit() # Cierra la aplicación

func cambiar_escena() -> void:
	var error = get_tree().change_scene_to_file(NIVEL_INICIO_PATH)
	if error != OK:
		print("ERROR al cargar escena: ", error)
		print("Verifica que la ruta sea correcta: ", NIVEL_INICIO_PATH)
