extends Node

# This Scene Switcher will transfer between the simulation
# and the ARPG world parts
# since each can be viewed as a separate game

# will handle transferring the data of the player and any other necessary info
# (note player inventory will be a child of the player)
var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("change_level", self, "_on_change_level")
	current_scene = load("res://World.tscn").instance()
	add_child(current_scene)

func change_scene(new_scene, old_scene):
	var inventory = old_scene.save_inventory()
	new_scene.load_inventory(inventory)
	

func _on_change_level(destinationScene):
	var new_scene = load(destinationScene).instance()
	new_scene.load_inventory(current_scene.save_inventory())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
