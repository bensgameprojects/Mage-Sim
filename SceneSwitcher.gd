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
onready var simulation = $Simulation
var current_scene_name
onready var health_ui = $UILayer/HealthUI
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
	health_ui.setup(player)
# this is called by a ZoneChanger node (see ZoneChanger.gd for details)
# ZoneChanger emits a level_change signal with the path to the destination scene
# This is resolved here.
func _on_SceneSwitcher_change_level(destination_scene_name):
	levelTransitionAnimation.play("fade_in")
	# stop the simulation timer while the level switches
	$Simulation/SimulationTimer.stop()
	# load an instance of the destination scene
	var new_scene = load(_build_scene_path(destination_scene_name)).instance()
	# get the player node from the current scene
	player = current_scene.remove_player()
	# set the new scene name
	current_scene_name = destination_scene_name
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
	simulation.setsup(current_scene_name, new_thing_tracker, new_power_system, ground_tiles, thing_placer, flat_things, player)
	# setup the entity_placer on the scene
	new_scene.setup_thing_placer(current_scene_name, new_thing_tracker, ground_tiles, flat_things, player)
	# remove the old scene
	remove_child(current_scene)
	# call the queue free on the old scene
	current_scene.queue_free()
	# reassign current scene var for next time
	current_scene = new_scene
	levelTransitionAnimation.play("fade_out")

func _build_scene_path(scene_name):
	var path = "res://Levels/" + scene_name + ".tscn"
	return path
	
