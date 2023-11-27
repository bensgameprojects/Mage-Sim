extends Control

var slots = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
var player
var is_open = false
var new_selected_node = ""
var selected_node = "N"
var assigned_action = "left_click"
var center : Vector2
var offset = Vector2(64,64)
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("assign_quickwheel", self, "_on_assign_quickwheel")
	self.visible = false
	offset = offset * self.rect_scale
	get_node(selected_node).self_modulate = Color.red
	get_node(selected_node).assign_ability("FireAttack1")
	yield(get_tree(), "idle_frame") # wait for a second so player can be ready to get this signal
	Events.emit_signal("update_action", assigned_action, get_node(selected_node).get_ability())

func _unhandled_input(event):
	if event.is_action_pressed("quickwheel_1"):
		is_open = true
		center = get_global_mouse_position() - offset
		self.set_global_position(center)
		self.visible = true
		new_selected_node = ""
	elif event.is_action_released("quickwheel_1"):
		is_open = false
		self.visible = false
		if new_selected_node != "": # a new node was selected
			var ability_name = get_node(new_selected_node).get_ability()
			if ability_name != null:
				get_node(selected_node).self_modulate = Color.white
				get_node(new_selected_node).self_modulate = Color.red
				selected_node = new_selected_node
				Events.emit_signal("update_action", assigned_action, ability_name)
			else:
				get_node(new_selected_node).self_modulate = Color.white


func _mouse_entered(name):
	new_selected_node = name
	get_node(new_selected_node).self_modulate = Color.aqua

func _mouse_exited(name):
	if(name == selected_node):
		get_node(name).self_modulate = Color.red
	else:
		get_node(name).self_modulate = Color.white
	new_selected_node = ""
	
func _on_assign_quickwheel(slot_name, selected_spell):
	get_node(slot_name).assign_ability(selected_spell)
	if(slot_name == selected_node):
		Events.emit_signal("update_action", assigned_action, selected_spell)

func _process(_delta):
	if self.visible:
		var mouse_pos = get_global_mouse_position()
		if (mouse_pos - offset - center).length() >= 4:
			var direction = center.direction_to(mouse_pos - offset)
			var angle = direction.angle()
			# truncate and divide the angle by 2PI/num_slots
			# same as multiply by 4 / PI in this case
			# modulo by slots.length in case of 2pi => 8 => 0
			var choice = slots[int(floor(angle * 4/PI)) % slots.size()]
			# new_selected_node is keeping track of what the user
			# is selecting when the menu is open
			# selected_node is the selected item from last time
			# a selection was confirmed
			# we are constantly updating choice while the 
			# menu is open and whenever it doesnt match new_selected_node
			# then we update that.
			if choice != new_selected_node:
				if new_selected_node != "":
					_mouse_exited(new_selected_node)
				else:
					_mouse_exited(selected_node)
				_mouse_entered(choice)
