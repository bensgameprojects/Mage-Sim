extends Control


var player
var is_open = false
var new_selected_node = ""
var selected_node = "N"
var assigned_action = "left_click"
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("assign_quickwheel", self, "_on_assign_quickwheel")
	self.visible = false
	get_node(selected_node).self_modulate = Color.red
	get_node(selected_node).assign_ability("FireAttack1")
	yield(get_tree(), "idle_frame") # wait for a second so player can be ready to get this signal
	Events.emit_signal("update_action",assigned_action, get_node(selected_node).get_ability())

func _unhandled_input(event):
	if event.is_action_pressed("quickwheel_1"):
		is_open = true
		self.set_global_position(get_global_mouse_position() - Vector2(64,64))
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
				Events.emit_signal("update_action",assigned_action, ability_name)
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
