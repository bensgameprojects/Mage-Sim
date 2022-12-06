extends Node2D


## A Spawn Location should be placed where the player will spawn
## It should always be placed below the SpawnHandler in the scene tree.
## Should always be hidden in the world
## Although it has no sprite (for now at least)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_position():
	return get("position")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
