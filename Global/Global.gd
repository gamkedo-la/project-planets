extends Node

var orbs_collected
var current_scene = null

var level_number = 1
var restart_level_number = 1

# keep track of the current level_path for reloading purposes
var current_level_path = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count()-1)
	print(current_scene)
	
	Events.connect("orb_collected", self, "increase_orb_count")
	orbs_collected = 0
	
func increase_orb_count():
	orbs_collected += 1
	
func reset_orb_count():
	orbs_collected = 0
	
func goto_scene(path, save_path=false):
	# save_path: should be set to true when loading a gameplay level (scenes we 
	# want to reload) and false for scenes like menus etc... (default is false)
	if save_path:
		current_level_path = path
	call_deferred("_deferred_goto_scene", path)
	
func _deferred_goto_scene(path):
	current_scene.queue_free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	
	reset_orb_count()
	
	get_tree().get_root().add_child(current_scene)
	
	#get_tree().set_current_scene(current_scene)
	
	print(current_scene)

