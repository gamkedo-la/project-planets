extends Node2D


var health_particles = load("res://Particles/HealthParticles.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_hit", self, "reduce_health")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reduce_health():
	$TextureProgress.value -= 3
	
	if $TextureProgress.value <= 0:
		Events.emit_signal("game_over_triggered")
