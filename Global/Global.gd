extends Node

var orbs_collected

func _ready():
	Events.connect("orb_collected", self, "increase_orb_count")
	orbs_collected = 0
	
func increase_orb_count():
	orbs_collected += 1

