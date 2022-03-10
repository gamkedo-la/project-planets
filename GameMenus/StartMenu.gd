extends Node

func _ready():
	$Title/BottomHalf_MainMenu/StartBtn.grab_focus()

func _on_StartBtn_pressed():
	print("Start Button pressed")
	get_tree().change_scene("res://Main.tscn")


func _on_OptionsBtn_pressed():
	print("Opitions Button pressed")


func _on_ExitBtn_pressed():
	print("Exit Button pressed")
	get_tree().quit()
