extends Control

func _input(event):
	if event.is_action_pressed("pause"):
		var pause_game = not get_tree().paused
		get_tree().paused = pause_game
		visible = pause_game
