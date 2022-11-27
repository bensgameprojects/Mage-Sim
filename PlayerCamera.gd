extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(float) var zoom_increment = 0.1
export(float) var max_zoom = 0.4
export(float) var min_zoom = 2.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func zoom_in():
	# only allow zoom out if its possible
	if zoom.x > max_zoom and zoom.y > max_zoom:
		zoom.x -= zoom_increment
		zoom.y -= zoom_increment

func zoom_out():
	# only allow zoom in if its possible
	if zoom.x < min_zoom and zoom.y < min_zoom:
		zoom.x += zoom_increment
		zoom.y += zoom_increment

func _unhandled_input(event):
	if event.is_action_pressed("ui_scroll_up"):
		zoom_in()
	elif event.is_action_pressed("ui_scroll_down"):
		zoom_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
