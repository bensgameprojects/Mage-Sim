extends PanelContainer

# Constant amount of pixels to nudge the panel up and to the right by
# That way it isnt directly under the mouse
const OFFSET := Vector2(16,-16)

# The current thing being hovered. Whenever the mouse moves,
# a new signal will be triggered even if the mouse did not move off of the 
# current thing. This would result in an unwanted flicker.
# We keep track of the current thing so we can choose not to update
# if we don't need to.
var current_thing: Node

onready var label := $MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	# Connect to the events
	Events.connect("hovered_over_thing", self, "_on_hovered_over_thing")
	Events.connect("info_updated", self, "_on_info_updated")
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rect_global_position = get_global_mouse_position() + OFFSET

func _set_info(thing: Node) -> void:
	var thing_info = BuildingList.get_building_by_id(BuildingList.get_thing_name_from(thing))
	var output : String = thing_info["name"]
	if thing.has_method("get_info"):
		var info: String = thing.get_info()
		if not info.empty():
			output += "\n%s" % info
	label.text = output
	# Make the tooltip visible
	show()

func _on_hovered_over_thing(thing: Node) -> void:
	if not thing == current_thing:
		current_thing = thing
		
	if not thing:
		label.text = ""
		hide()
	else:
		_set_info(thing)
		# This attempt to resize the panel to '0' next frame
		# which will force the container to update to its minimum size
		# which should fit the label snuggly
		set_deferred("rect_size", Vector2.ZERO)

func _on_info_updated(thing: Node) -> void:
	if current_thing and thing == current_thing:
		_set_info(current_thing)
		set_deferred("rect_size", Vector2.ZERO)
