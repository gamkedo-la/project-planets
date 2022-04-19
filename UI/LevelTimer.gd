extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(15)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimerLabel.text = str(int($Timer.time_left))
#	pass


func _on_Timer_timeout():
	Global.goto_scene("res://GameMenus/GameOverMenu.tscn")
	pass # Replace with function body.
