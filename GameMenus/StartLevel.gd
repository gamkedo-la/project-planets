extends Control

onready var only_once : bool = true
var ready_for_input = false

func _ready():
	get_tree().paused = true
	$TopHalf/LevelNameLabel.text = "Level " + str(Global.level_number)
	
func _input(event):
	if event is InputEventKey && ready_for_input:
		if event.pressed && only_once:
			var start_level_pause = not get_tree().paused
			get_tree().paused = start_level_pause
			visible = start_level_pause
			only_once = false	
			$AudioStreamPlayer.playing = false




func _on_Timer_timeout():
	ready_for_input = true
	pass # Replace with function body.
