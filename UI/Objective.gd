extends Node2D

var score

func _ready():
	score = 0
	print("Score is " + str(score))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if score != Global.orbs_collected:
		score = Global.orbs_collected
		$AnimationPlayer.play("score_increase")
		$Control/ObjectiveRequirement.text = str(score) + " / 100"
		print("Score is " + $Control/ObjectiveRequirement.text)
#	pass
