extends Label

const heal_color = Color(0.113725, 0.760784, 0.12549)
const fire_color = Color(0.760784, 0.113725, 0.113725)
const lightning_color = Color(0.760784, 0.614185, 0.113725)
const water_color = Color(0.113725, 0.320987, 0.760784)
const earth_color = Color(0.47451, 0.227451, 0.066667)
#onready var tween = $Tween
const duration = 0.8

onready var tween = $Tween
const position_offset := Vector2(0,-20)
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	#self.visible = false # Replace with function body.
	self.visible = false

func display_value(value: float, element_type: String, position: Vector2):
	# truncate to whole number and then to string
	self.rect_position = position + Vector2(rng.randi_range(-20,20),rng.randi_range(-25,-10))
	self.text = str(int(value))
	apply_element_effect(element_type)
	self.visible = true
	tween.interpolate_property(self, "rect_position", self.rect_position,
	self.rect_position - Vector2(3,16),duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0.4,0.4),
	duration,Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self,"modulate", Color(1,1,1,1), Color(1,1,1,0.75), duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func apply_element_effect(element_type: String):
	match(element_type):
		"HEAL": add_color_override("font_color", heal_color)
		"FIRE": add_color_override("font_color", fire_color)
		"WIND": add_color_override("font_color", lightning_color)
		"WATER": add_color_override("font_color", water_color)
		"EARTH": add_color_override("font_color", earth_color)
		_: add_color_override("font_color", Color.white)

func _on_Tween_tween_all_completed():
	self.queue_free()
