extends Control

onready var only_once : bool = true

func _ready():
	get_tree().paused = true
	$TopHalf/LevelNameLabel.text = "Level " + str(Global.level_number)
	
func _input(event):
	if event is InputEventKey:
		if event.pressed && only_once:
			var start_level_pause = not get_tree().paused
			get_tree().paused = start_level_pause
			visible = start_level_pause
			only_once = false	


