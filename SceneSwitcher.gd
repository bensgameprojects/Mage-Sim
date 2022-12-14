extends Node

# This Scene Switcher will transfer between the simulation
# and the ARPG world parts
# since each can be viewed as a separate game
# The SceneSwitcher is the SOLE MEMBER of the group called SceneSwitcher which
# can be used to find this node and connect with it like this:
# var scene_switcher = get_tree().get_nodes_in_group("SceneSwitcher")[0]
# then you can connect to it with connect(signal, scene_switcher, method_name)
# from wherever you are

var player_scene = preload("res://Player/Player.tscn")
# will handle transferring the data of the player and any other necessary info
# (note player inventory will be a child of the player)
var current_scene
var player
onready var levelTransitionAnimation = $SceneTransition/LevelTransitionAnimation
onready var health_ui = $UILayer/HealthUI
# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene = load("res://Levels/World.tscn").instance()
	add_child(current_scene)
	player = player_scene.instance()
	current_scene.add_player(player)
	health_ui.setup(player)
# this is called by a ZoneChanger node (see ZoneChanger.gd for details)
# ZoneChanger emits a level_change signal with the path to the destination scene
# This is resolved here.
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
