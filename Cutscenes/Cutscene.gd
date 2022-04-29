extends Node2D
export var next_scene = "res://Cutscenes/CutscenePartTwo.tscn"
onready var dialogue = preload("res://Dialogue/Scripts/intro.tres")
export var diag_node = "start"

func _ready():
	Global.next_cutscene = next_scene
	DialogueManager.show_example_dialogue_balloon(diag_node, dialogue)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func trigger_dialogue():
	#DialogueManager.show_example_dialogue_balloon(diag_node, dialogue)
	pass

func _progress_to_next_scene():
	Global.goto_scene(next_scene)
	pass
