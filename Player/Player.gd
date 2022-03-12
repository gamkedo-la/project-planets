extends KinematicBody2D

export (PackedScene) var bullet
var reward_particle = load("res://Particles/RewardParticles.tscn")

var move_speed = 100 # pixels/sec
var fire_rate = 10
onready var update_delta = 1 / fire_rate
var current_time = 0

func _ready():
	Events.connect("orb_collected", self, "spawn_reward_particle")


func _physics_process(delta):
	current_time += delta
	
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += move_speed * delta
	if Input.is_action_pressed("ui_left"):
		rotation_degrees -= move_speed * delta
	if Input.is_action_pressed("ui_down"):
		if current_time < update_delta:
			return
		current_time = 0
		$AnimationPlayer.play("fire_bullet")


func shoot():
	var b = bullet.instance()
	owner.add_child(b)
	b.transform = $BulletSpawnPosition.global_transform
	
func spawn_reward_particle():
	var p = reward_particle.instance()
	$PlayerSprite.add_child(p)
	# p.transform = $PlayerSprite.global_transform
