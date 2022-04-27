extends Node2D

var score
export var score_objective = 0
export var next_level = "res://Levels/Level_1.tscn"

func _ready():
	score = 0
	$Control/ObjectiveRequirement.text = str(score) + " / " + str(score_objective)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if score != Global.orbs_collected:
		score = Global.orbs_collected
		$AnimationPlayer.play("score_increase")
		$Control/ObjectiveRequirement.text = str(score) + " / " + str(score_objective)
		
	if score >= score_objective:
		#Global.reset_orb_count()
		Global.level_number += 1
		$Transition.transition()
		#Global.goto_scene(next_level, true)


func _on_Transition_transitioned():
	Global.goto_scene(next_level, true)
