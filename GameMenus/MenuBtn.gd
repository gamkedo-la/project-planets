tool
extends TextureButton

export(String) var text = "Menu Button Text"
export(int) var arrow_margin_from_center = 100

func _ready():
	setup_text()
	hide_arrow()
	set_focus_mode(true)
	
func _process(delta):
	if Engine.editor_hint:
		setup_text()
		show_arrow()
	
func setup_text():
	$RichTextLabel.bbcode_text = "[center] %s [/center]" % [text]

func show_arrow():
	for arrow in [$MenuPointer]:
		arrow.visible = true
		arrow.global_position.y = rect_global_position.y + (rect_size.y / 3.0)
		
		var center_x = rect_global_position.x + (rect_size.x / 2)
		$MenuPointer.global_position.x = center_x - arrow_margin_from_center

func hide_arrow():
	for arrow in [$MenuPointer]:
		arrow.visible = false

func _on_MenuBtn_focus_entered():
	show_arrow() # show menu pointer
	get_node("RichTextLabel").add_color_override("default_color", Color(1.0,0.6,0.0,1.0))
	# change color of text to ffa300

func _on_MenuBtn_focus_exited():
	hide_arrow() # hide menu pointer
	get_node("RichTextLabel").add_color_override("default_color", Color(1.0,0.94,0.9,1.0))
	# change color of text to fff1e8
	
func _on_MenuBtn_mouse_entered():
	grab_focus()
	


