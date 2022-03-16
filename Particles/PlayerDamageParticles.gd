extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# $Timer.start()
	pass # Replace with function body.



func _on_Timer_timeout():
	queue_free()
