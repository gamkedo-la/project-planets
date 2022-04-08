extends CanvasLayer

signal transitioned

func _ready():
	#transition()
	$ColorRect.visible = false

func transition():
	$ColorRect.visible = true
	$AnimationPlayer.play("FadeOut")
	print("fading out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		print("emit fading signal")
		$AnimationPlayer.play("FadeIn")
		emit_signal("transitioned")
	if anim_name == "FadeIn":
		print("finished fading")
		$ColorRect.visible = false
		
