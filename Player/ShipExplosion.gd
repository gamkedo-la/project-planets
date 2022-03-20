extends Sprite

func _ready():
	Events.connect("game_over_triggered", self, "explode_player")
	

func explode_player():
	visible = true
	$AnimationPlayer.play("explosion")


func _on_AnimationPlayer_animation_finished(anim_name):
	Events.emit_signal("player_exploded")
	visible = false
