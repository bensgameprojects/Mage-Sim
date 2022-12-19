extends TextureButton


var assigned_ability
onready var ability_label = $ability_label

# Called when the node enters the scene tree for the first time.
func _ready():
	ability_label.rect_position = Vector2(0,16)
	ability_label.align = Label.ALIGN_CENTER

func assign_ability(ability_name):
	assigned_ability = ability_name
	ability_label.text = assigned_ability

func get_ability() -> String:
	return assigned_ability


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
