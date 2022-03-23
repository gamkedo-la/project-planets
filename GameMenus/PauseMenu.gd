extends Control

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused
		$Title/BottomHalf_PauseMenu/ResumeBtn.grab_focus()
		
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
 
func _on_ResumeBtn_pressed():
	print("Resume Button pressed")
	self.is_paused = false
	
func _on_RestartBtn_pressed():
	print("Restart Button pressed")
	Global.goto_scene("res://Levels/Level_1.tscn")
	self.is_paused = false

func _on_QuitBtn_pressed():
	print("Quit Button pressed")
	Global.goto_scene("res://GameMenus/StartMenu.tscn")
	self.is_paused = false

func _on_ExitBtn_pressed():
	print("Exit Button pressed")
	get_tree().quit()
