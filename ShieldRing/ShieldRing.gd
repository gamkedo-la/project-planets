extends Node2D

export var difficulty = "easy"
export var difficulty_speed = 1.5

func _ready():
	if difficulty == "none":
		$Easy.queue_free()
		$Medium.queue_free()
		$Hard.queue_free()
		$Impossible.queue_free()
	elif difficulty == "easy":
		$Medium.queue_free()
		$Hard.queue_free()
		$Impossible.queue_free()
		$AnimationPlayer.play("EasySpin")
	elif difficulty == "medium":
		$Hard.queue_free()
		$Impossible.queue_free()
		$AnimationPlayer.play("MediumSpin")
	elif difficulty == "hard":
		$Impossible.queue_free()
		$AnimationPlayer.play("HardSpin")
		
	$AnimationPlayer.playback_speed = difficulty_speed
