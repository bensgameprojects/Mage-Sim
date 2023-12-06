extends Control

var slots = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
var player
var new_selected_node = ""
var selected_node = "E"
var assigned_action = "left_click"
var center : Vector2
var offset = Vector2(64,64)
# Called when the node enters the scene tree for the first time.
func _ready():
	# center of the centerContainer(square)
	offset = $CenterContainer.rect_size * self.rect_scale / (2)
	Events.connect("assign_quickwheel", self, "_on_assign_quickwheel")
	self.visible = false
	#offset = offset * self.rect_scale
	get_node(selected_node).play_selected_animation()
	get_node(selected_node).assign_ability("Fireball")
	#yield(get_tree(), "idle_frame") # wait for a second so player can be ready to get this signal
	_update_action(assigned_action, get_node(selected_node).get_ability())

func _unhandled_input(event):
	if event.is_action_pressed("quickwheel_1"):
		center = get_global_mouse_position() - offset
		self.set_global_position(center)
		self.visible = true
		get_node(selected_node).play_selected_animation()
		new_selected_node = ""
	elif event.is_action_released("quickwheel_1"):
		self.visible = false
		get_node(selected_node).clear_highlight()
		get_node(selected_node).stop_selected_animation()
		if new_selected_node != "": # a new node was selected
			var ability_name = get_node(new_selected_node).get_ability()
			if ability_name != "":
				selected_node = new_selected_node
				_update_action(assigned_action, ability_name)
			get_node(new_selected_node).clear_highlight()


func _mouse_entered(name):
	new_selected_node = name
	#get_node(new_selected_node).self_modulate = Color.aqua
	get_node(name).highlight()

func _mouse_exited(name):
	get_node(name).clear_highlight()
	"""
	if(name == selected_node):
		get_node(name).play_selected_animation()
	else:
		get_node(name).stop_selected_animation()
	new_selected_node = ""
	"""
	
func _on_assign_quickwheel(slot_name, selected_spell):
	get_node(slot_name).assign_ability(selected_spell)
	if(slot_name == selected_node):
		_update_action(assigned_action, selected_spell)

func _process(_delta):
	if self.visible:
		var mouse_pos = get_global_mouse_position()
		if (mouse_pos - offset - center).length() >= $CenterContainer.rect_size.x * self.rect_scale.x / 6:
			var direction = center.direction_to(mouse_pos - offset)
			var angle = direction.angle()
			# truncate and divide the angle by 2PI/num_slots
			# same as multiply by 4 / PI in this case
			# modulo by slots.length in case of 2pi => 8 => 0
			var choice = slots[int(round(angle * 4/PI)) % slots.size()]
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

func _update_action(action: String, ability: String):
	if action == "left_click":
		PlayerStats.left_click_ability = PlayerStats.load_ability(ability)
		PlayerStats.left_click_ability_id = ability
	elif action == "right_click":
		PlayerStats.right_click_ability = PlayerStats.load_ability(ability)
		PlayerStats.right_click_ability_id = ability
