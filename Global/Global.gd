extends Node

var orbs_collected
var current_scene = null;

func _ready():
	Events.connect("orb_collected", self, "increase_orb_count")
	orbs_collected = 0
	
func increase_orb_count():
	orbs_collected += 1

