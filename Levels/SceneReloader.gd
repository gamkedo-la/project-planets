extends Control

func _ready():
#	Global.current_scene = get_tree().current_scene.filename
	pass

func _unhandled_input(event):
	if event.is_action_pressed("reload"):
		Global.reset_orb_count()
		Global.goto_scene(Global.current_level_path)
