extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# FIXME why does this never get triggered? =(
func _on_Timer_timeout():
	queue_free()
