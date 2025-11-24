extends Node

@export var musica_global: AudioStream
@onready var reproductor = $AudioStreamPlayer

func _ready():
	# Usar call_deferred asegura que todos los @onready se hayan resuelto y 
	# que todos los nodos hijos estén en el árbol antes de manipularlos.
	call_deferred("iniciar_musica")

func iniciar_musica():
	# Verifica dos veces que el @onready funcionó
	if not is_instance_valid(reproductor):
		print("ERROR CRÍTICO: El nodo 'Reproductor' no fue encontrado.")
		return
		
	# Asignamos el stream de música
	if musica_global:
		reproductor.stream = musica_global
	
	# Nos aseguramos de que empiece
	if reproductor.stream and not reproductor.playing:
		reproductor.play()
