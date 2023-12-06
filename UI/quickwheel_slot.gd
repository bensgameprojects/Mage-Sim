extends TextureButton


var assigned_ability : String = ""
onready var ability_label = $ability_label
onready var sprite = $AnimatedSprite
onready var icon = $ability_icon
# Called when the node enters the scene tree for the first time.
func _ready():
	ability_label.rect_position = Vector2(0,16)
	ability_label.align = Label.ALIGN_CENTER
	icon.visible = false

func assign_ability(ability_name: String):
	assigned_ability = ability_name
	ability_label.text = assigned_ability
	icon.texture = load("res://Assets/Abilities/" + ability_name + "/" + ability_name + "-icon-large.png")
	icon.visible = true

func get_ability() -> String:
	return assigned_ability

func play_selected_animation():
	sprite.playing = true

func stop_selected_animation():
	sprite.playing = false
	sprite.frame = 0

func highlight():
	sprite.self_modulate = Color(0.89, 0.81, 0.78, 1.0)

func clear_highlight():
	sprite.self_modulate = Color.white

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

