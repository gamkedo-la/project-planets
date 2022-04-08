
# HEALTHPACK
# similar to ore - a pickup that moves toward the player
# sends healthpack_collected signal when collected

extends KinematicBody2D

var speed = 100
var velocity = Vector2.ZERO
var player = null

func _ready():
	#player = owner.get_node("Planet").get_node("Player").get_node("PlayerSprite")
	#print(player.global_position)
	pass
	

func _process(delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.global_position) * speed
		look_at(player.global_position)
	velocity = move_and_slide(velocity)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if collision.collider.name == "Player":
			Events.emit_signal("healthpack_collected")
			queue_free()
	

func _on_Area2D_area_entered(area):
	if area.is_in_group("player"): 
		player = area.owner.get_node("PlayerSprite")
