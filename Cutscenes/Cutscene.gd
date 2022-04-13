extends Node2D
export var next_scene = "res://Cutscenes/CutscenePartTwo.tscn"

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _progress_to_next_scene():
	Global.goto_scene(next_scene)
	pass
