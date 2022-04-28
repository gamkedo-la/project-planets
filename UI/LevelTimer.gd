extends Control


export var time_limit = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start(time_limit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimerLabel.text = str(int($Timer.time_left))
#	pass


func _on_Timer_timeout():
	Global.goto_scene("res://GameMenus/GameOverMenu.tscn")
	pass # Replace with function body.
