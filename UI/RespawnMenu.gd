extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	Events.connect("player_died", self, "show_menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_menu():
	self.show()

func _on_Button_pressed():
	Events.emit_signal("respawn_player")
	self.hide()
