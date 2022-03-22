extends Control

func _ready():
	Global.current_scene = get_tree().current_scene.filename

func _unhandled_input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
