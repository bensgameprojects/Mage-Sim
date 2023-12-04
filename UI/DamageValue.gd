extends Label

#onready var tween = $Tween
const duration = 0.8

onready var tween = $Tween
const position_offset := Vector2(0,-20)
# Called when the node enters the scene tree for the first time.
func _ready():
	#self.visible = false # Replace with function body.
	self.visible = false
	#display_value(3, Vector2(16,16))

func display_value(value: float, position: Vector2):
	# truncate to whole number and then to string
	self.rect_position = position + position_offset
	self.text = str(int(value))
	self.visible = true
	tween.interpolate_property(self, "rect_position", self.rect_position,
	self.rect_position - Vector2(3,16),duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_scale", Vector2(1,1), Vector2(0.3,0.3),
	duration,Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self,"modulate", Color(1,1,1,1), Color(1,1,1,0), duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()
