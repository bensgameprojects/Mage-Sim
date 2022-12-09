class_name BlueprintThing
extends Node2D


## Whether the player can place this object in the world. For example, a lumber axe.
## should not be 'placed' like a machine.
export var placeable := true

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 9


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
