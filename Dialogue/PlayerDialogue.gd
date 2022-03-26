extends CanvasLayer

export(String, FILE, "*.json") var dialogue_file

var dialogues = []
var current_dialogue_id = 0

func _ready():
	play()
	
func play():
	dialogues = load_dialogue()
	
	current_dialogue_id = -1
	next_line()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		next_line()
		
func next_line():
	print(current_dialogue_id)
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogues):
		print("End of dialogue")
		queue_free()
		Global.goto_scene("res://Levels/Level_1.tscn")
		return
		
	var file = File.new()
	var img = "res://Dialogue/" + dialogues[current_dialogue_id]["fileName"] + ".png"
	
	if file.file_exists(img):
		$DialogUI/Avatar.texture = load(img)
	else: $DialogUI/Avatar.texture = null
	
	$DialogUI/DialogBox/Name.text = dialogues[current_dialogue_id]["name"]	
	$DialogUI/DialogBox/Dialogue.text = dialogues[current_dialogue_id]["text"]
	
func load_dialogue():
	var file = File.new()
	
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		return parse_json(file.get_as_text())
