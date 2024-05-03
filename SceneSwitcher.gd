extends Node

# This Scene Switcher will transfer between game scenes and
# eventually also menu scenes. This node also handles 
# the saving and loading.

var player_scene = preload("res://Player/Player.tscn")
# will handle transferring the data of the player and any other necessary info
# (note player inventory will be a child of the player)
var current_scene
var player
onready var levelTransitionAnimation := $SceneTransition/LevelTransitionAnimation
onready var simulation := $Simulation
var current_scene_name : String
var scene_save_states : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene_name = "Home"
	current_scene = load(_build_scene_path(current_scene_name)).instance()
	add_child(current_scene)
	player = player_scene.instance()
	current_scene.add_player(player)
	# get the ground tiles and other stuff for the simulation system
	var ground_tiles = current_scene.get_ground_tiles()
	var thing_placer = current_scene.get_thing_placer()
	var flat_things = current_scene.get_flat_things()
	var new_thing_tracker = ThingTracker.new()
	var new_power_system = PowerSystem.new()
	var new_work_system = WorkSystem.new()
	simulation.setup(current_scene_name, new_thing_tracker, new_power_system, new_work_system, ground_tiles, thing_placer, flat_things, player)
	current_scene.setup_thing_placer(current_scene_name, new_thing_tracker, ground_tiles, flat_things, player)
	Events.connect("change_level", self, "_on_SceneSwitcher_change_level")
	Events.connect("respawn_player", self, "_on_SceneSwitcher_change_level", ["Home"])
#	Events.connect("player_died", self, "pause_game")
	

# ZoneChanger emits a level_change signal with the name of the destination scene
# This is resolved here.
func _on_SceneSwitcher_change_level(destination_scene_name: String):
	levelTransitionAnimation.play("fade_in")
	# stop the simulation timer while the level switches
	pause_game()
	# get the player node from the current scene
	player = current_scene.remove_player()
	scene_save_states[current_scene_name] = save_current_scene()
	# set the new scene name
	current_scene_name = destination_scene_name
	# remove the old scene
	remove_child(current_scene)
	# call the free on the old scene since everything is handled
	current_scene.queue_free()
	# load an instance of the destination scene
	var new_scene = load(_build_scene_path(destination_scene_name)).instance()
	# reassign current scene var for next time
	current_scene = new_scene
	# add the new scene
	add_child(new_scene)
	# add the player to the new scene
	new_scene.add_player(player)
	# get the ground tiles and other stuff for the simulation system
	var ground_tiles = new_scene.get_ground_tiles()
	var thing_placer = new_scene.get_thing_placer()
	var flat_things = new_scene.get_flat_things()
	var new_thing_tracker = ThingTracker.new()
	var new_power_system = PowerSystem.new()
	var new_work_system = WorkSystem.new()
	# setup the thing_placer on the scene
	new_scene.setup_thing_placer(current_scene_name, new_thing_tracker, ground_tiles, flat_things, player)
	# then the trackers and systems are given to the simulation.
	simulation.setup(current_scene_name, new_thing_tracker, new_power_system, new_work_system, ground_tiles, thing_placer, flat_things, player)
	if scene_save_states.has(destination_scene_name):
		load_scene(scene_save_states[destination_scene_name])
	levelTransitionAnimation.play("fade_out")
	resume_game()

func _build_scene_path(scene_name):
	var path = "res://Levels/" + scene_name + ".tscn"
	return path

func pause_game():
	# This flag should pause all the process functions
	# https://docs.godotengine.org/en/4.0/tutorials/scripting/pausing_games.html
	get_tree().paused = true
	# This function should pause all the things in the simulation (buildings)
	simulation.pause()
	# Might want a signal for pausing/resuming.
	# probably will need another function to set a pause state in the menus?
	# for now it will be ok.
	
func resume_game():
	get_tree().paused = false
	simulation.resume()

# All the persistent nodes in the SaveScene group. Currently just the Simulation node,
# but will be expanded to include the Spawnhandler node for enemies.
# A node added to the save group should exist in the tree when loaded
# SaveScene is all the nodes needed to save the scene
# A full save group for the player's inventory, stats etc will be added later
func save_current_scene() -> Dictionary:
	var save_dict := {}
	for node  in get_tree().get_nodes_in_group("SceneSave"):
		save_dict[node.name] = node.save()
	#save_dict["simulation"] = simulation.save()
	return save_dict

func load_scene(save_dict: Dictionary):
	for node in get_tree().get_nodes_in_group("SceneSave"):
		node.load_state(save_dict[node.name])
