extends Node

# This Scene Switcher will transfer between the simulation
# and the ARPG world parts
# since each can be viewed as a separate game

var player_scene = preload("res://Player/Player.tscn")
# will handle transferring the data of the player and any other necessary info
# (note player inventory will be a child of the player)
var current_scene

onready var levelTransitionAnimation = $SceneTransition/LevelTransitionAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene = load("res://Levels/World.tscn").instance()
	add_child(current_scene)
	current_scene.add_player(player_scene.instance())

#func change_scene(new_scene, old_scene):
#	var inventory = old_scene.save_inventory()
#	new_scene.load_inventory(inventory)
#
#
#func _on_change_level(destinationScene):
#	var new_scene = load(destinationScene).instance()
#	new_scene.load_inventory(current_scene.save_inventory())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SceneSwitcher_change_level(destination_scene_path):
	levelTransitionAnimation.play("fade_in")
	# load an instance of the destination scene
	var new_scene = load(destination_scene_path).instance()
	# get the player node from the current scene
	var player_instance = current_scene.remove_player()
	# add the new scene
	add_child(new_scene)
	# add the player to the new scene
	new_scene.add_player(player_instance)
	# remove the old scene
	remove_child(current_scene)

	# call the queue free on the old scene
	current_scene.queue_free()
	# reassign current scene var for next time
	current_scene = new_scene
	levelTransitionAnimation.play("fade_out")
