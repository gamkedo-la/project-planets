extends Control

func _ready():
	Global.current_scene = get_tree().current_scene.filename

func _unhandled_input(event):
	if event.is_action_pressed("reload"):
		if Global.orbs_collected > 0:
			Global.orbs_collected = 0
		get_tree().reload_current_scene()
