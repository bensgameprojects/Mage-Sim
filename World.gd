extends Node2D


onready var spawnHandler = $SpawnHandler
onready var inventoryUI = $"UI Base/InventoryUI"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_inventory(inventory):
	inventoryUI.load_inventory(inventory)

func save_inventory(inventory):
	return inventoryUI.save_inventory()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
