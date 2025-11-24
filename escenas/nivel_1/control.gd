extends Control

@onready var menu: Control = self
@onready var button: Button = $VBoxContainer/Button
@onready var button_2: Button = $VBoxContainer/Button2
@onready var button_3: Button = $VBoxContainer/Button3

func _ready():
	menu.hide()

func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		pause_or_unpause()
 
func pause_or_unpause():
	if get_tree().paused:
		menu.hide()
		get_tree().paused = false
	else:
		menu.show()
		get_tree().paused = true

func _on_resume_pressed():
	pause_or_unpause()

func _on_quit_pressed():
	get_tree().quit()


func _on_pause_pressed() -> void:
	pass # Replace with function body.
