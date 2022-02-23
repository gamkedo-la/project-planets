extends Area2D

var speed = 200

func _ready():
	pass

func _physics_process(delta):
	position += transform.y * speed * delta

	


func _on_Bullet_area_entered(area):
	if area.get_parent().is_in_group("planet"):
		speed = 0
		area.get_parent().spawn_reward($ImpactFX.global_transform)
		$AnimationPlayer.play("hit_fx")

	elif area.get_parent().is_in_group("shield"):
		# $AnimationPlayer.play("hit_fx")
		pass

func destroy_self():
	queue_free()
		
		

