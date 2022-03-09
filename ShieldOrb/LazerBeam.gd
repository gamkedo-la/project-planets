extends RayCast2D

var is_casting := false setget set_is_casting

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO
	
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#self.is_casting = event.pressed

func _physics_process(delta: float) -> void:
	var cast_point := cast_to
	force_raycast_update()
	
	$CollidingParticles2D.emitting = is_colliding()
	
	if is_colliding():
		if get_collider().is_in_group("player"):
			Events.emit_signal("player_hit")
		
		cast_point = to_local(get_collision_point())
		$CollidingParticles2D.global_rotation = get_collision_normal().angle()
		$CollidingParticles2D.position = cast_point
		
	$Line2D.points[1] = cast_point
	$BeamParticles2D.position = cast_point * 0.5
	$BeamParticles2D.process_material.emission_box_extents.x = cast_point.length() * 0.5
	
func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$BeamParticles2D.emitting = is_casting
	$CastingParticles2D.emitting = is_casting
	
	if is_casting:
		appear()
	else:
		$CollidingParticles2D.emitting = false
		disappear()
	
	set_physics_process(is_casting)
	
func appear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
	$Tween.start()
	
func disappear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 10.0, 0, 0.1)
	$Tween.start()
