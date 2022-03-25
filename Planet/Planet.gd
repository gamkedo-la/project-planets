extends Node2D

export (PackedScene) var ore


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("planet_hit", self, "spawn_reward")


func spawn_reward(pos):
	var o = ore.instance()
	call_deferred("add_reward_to_scene",o)
	#Global.current_scene.add_child(o)
	#Global.call_deferred("add_child",o)
	o.transform = pos
	
	shake_planet()
	
func shake_planet():
	$Shaker.start()
	
func add_reward_to_scene(o):
	Global.current_scene.add_child(o)

