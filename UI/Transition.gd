extends CanvasLayer

signal transitioned

onready var anim = $AnimationPlayer

func _ready():
	$ColorRect.visible = false

func transition():
	$ColorRect.visible = true
	anim.play("FadeIn")
	print("fading out")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		Global.reset_orb_count()
		anim.play("FadeOut")
		emit_signal("transitioned")
	if anim_name == "FadeOut":
		$ColorRect.visible = false
		
