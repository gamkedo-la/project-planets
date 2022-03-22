extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	$Title/BottomHalf_MainMenu/StartBtn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RestartBtn_pressed():
	get_tree().change_scene(Global.current_scene)

func _on_ExitBtn_pressed():
	print("Exit Button pressed")
	get_tree().quit()

func _on_MenuBtn_pressed():
	print("Loading main menu")
	get_tree().change_scene("res://GameMenus/StartMenu.tscn")
