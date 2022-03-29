extends CanvasLayer

export(String, FILE, "*.json") var dialogue_file
export(float) var dialogSpeed = 0.05

var dialogues = []

var current_dialogue_id = 0
var finished = false


func _ready():
	$DialogUI/Timer.wait_time = dialogSpeed
	play()
	
func play():
	if finished:
		return
		
	dialogues = load_dialogue()
	print("player controls function call")
	
	next_line()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if finished:
			next_line()
		else:
			$DialogUI/DialogBox/Dialogue.visible_characters = len($DialogUI/DialogBox/Dialogue.text)
			dialogue_indicator()
		
func next_line():
	$DialogUI/DialogBox/Indicator.visible = false
	
	if current_dialogue_id >= len(dialogues):
		queue_free()
		$DialogUI.visible = false
		return
		
	finished = false
		
	var file = File.new()
	var img = "res://Dialogue/" + dialogues[current_dialogue_id]["picName"] + ".png"
	
	if file.file_exists(img):
		$DialogUI/Avatar.texture = load(img)
	else: $DialogUI/Avatar.texture = null
	
	$DialogUI/DialogBox/Name.text = dialogues[current_dialogue_id]["name"]	
	$DialogUI/DialogBox/Dialogue.text = dialogues[current_dialogue_id]["text"]
	
	$DialogUI/DialogBox/Dialogue.visible_characters = -1
	
	while $DialogUI/DialogBox/Dialogue.visible_characters < len($DialogUI/DialogBox/Dialogue.text):
		$DialogUI/DialogBox/Dialogue.visible_characters += 1
		
		$DialogUI/Timer.start()
		yield($DialogUI/Timer, "timeout")
		
	finished = true
	dialogue_indicator()
	current_dialogue_id += 1
	return
	
func load_dialogue():
	var file = File.new()
	
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		return parse_json(file.get_as_text())		

func dialogue_indicator():
	$DialogUI/DialogBox/Indicator.visible = true
	$DialogUI/DialogBox/Indicator/AnimationPlayer.play("Bounce")
