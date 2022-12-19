extends Control

var spell_dir = "res://Abilities/Abilities/"
var spell_names = []
var quickwheel_positions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
onready var spell_list = $SpellList
onready var quickwheel_slot_menu = $SpellList/QuickwheelSlotMenu
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	spell_names = get_spell_names()
	for spell in spell_names:
		spell_list.add_item(spell)
	for position in quickwheel_positions:
		quickwheel_slot_menu.add_item(position)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.visible:
		self.visible = false

func get_spell_names() -> Array:
	var dir := Directory.new()
	if dir.open(spell_dir) != OK:
		printerr("Warning: could not open directory: ", spell_dir)
		return []
	if dir.list_dir_begin(true,true) != OK:
		printerr("Warning: could not list contents of: ", spell_dir)
		return []
	var spells := []
	var fileName := dir.get_next()
	
	while fileName != "":
		if not dir.current_is_dir():
			if fileName.get_extension() == "tscn":
				spells.append(fileName.get_basename())
		fileName = dir.get_next()
	return spells
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SpellList_item_activated(index):
	var selected_spell = spell_list.get_item_text(index)
	quickwheel_slot_menu.visible = true
	quickwheel_slot_menu.connect("index_pressed", self, "_on_quickwheel_slot_choice", [selected_spell], CONNECT_ONESHOT)

func _on_quickwheel_slot_choice(index:int, selected_spell: String):
	Events.emit_signal("assign_quickwheel", quickwheel_slot_menu.get_item_text(index), selected_spell)


func _on_SpellbookToggle_pressed():
	self.visible = not self.visible
