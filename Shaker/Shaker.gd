extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var original_position = Vector2()

onready var node_to_shake = get_parent()
#var original_position = node_to_shake.global_position

func _ready():
	original_position = node_to_shake.position
	print(original_position)

func start(duration = 0.1, frequency = 30, amplitude = 8):
	self.amplitude = amplitude
	
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	
	new_shake()

func new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude) + original_position.x
	rand.y = rand_range(-amplitude, amplitude) + original_position.y
	
	$ShakeTween.interpolate_property(node_to_shake, "position", node_to_shake.position, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	
func reset():
	$ShakeTween.interpolate_property(node_to_shake, "position", node_to_shake.position, original_position, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()


func _on_Frequency_timeout():
	new_shake()


func _on_Duration_timeout():
	reset()
	$Frequency.stop()
