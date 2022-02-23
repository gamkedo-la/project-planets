extends Node2D

export (PackedScene) var ore


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_reward(pos):
	var o = ore.instance()
	owner.add_child(o)
	o.transform = pos
