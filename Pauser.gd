extends Node

# A basic pause/unpause system for the game.
# Needs expansion when the main menu gets included and stuff
# Also to allow unpauseable pauses like for system saves and whatnot.
# This node has its pause mode set to always process so even when
# the paused flag is set, the input function will still run here.
# Check out this doc for more info on what gets paused.
# https://docs.godotengine.org/en/4.0/tutorials/scripting/pausing_games.html

var scene_switcher : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_switcher = get_tree().get_nodes_in_group("SceneSwitcher")[0]

func _unhandled_input(event):
	if event.is_action_pressed("ui_page_up"):
		if get_tree().paused:
			scene_switcher.resume_game()
		else:
			scene_switcher.pause_game()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
