extends Node2D


func _ready():
	print(Global.name)
	
func _process(delta):
	if Input.is_action_pressed("ui_down"):
		$AnimationPlayer.play("transition")
		
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://GameMenus/StartMenu.tscn")
		
func transition_scenes():
	get_tree().change_scene("res://Main.tscn")
	

