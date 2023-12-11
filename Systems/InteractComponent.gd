extends Area2D

signal interact_pressed

var prompt := ""


func _on_InteractComponent_area_entered(area):
	Events.emit_signal("interact_entered_range", self)

func _on_InteractComponent_area_exited(area):
	Events.emit_signal("interact_exited_range", self)

func set_prompt(new_prompt: String):
	prompt = new_prompt

func get_prompt():
	return prompt
