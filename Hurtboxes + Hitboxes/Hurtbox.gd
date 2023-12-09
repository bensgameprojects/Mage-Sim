class_name Hurtbox
extends Area2D

onready var hit_sound = $AudioStreamPlayer
#takes a spell_id string and the position
# parent of the hurtbox will connect to this signal to process
# what that means for them.
signal hit_by(spell_id, given_position)

const HitEffect = preload("res://Effects/HitEffect.tscn")

func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func set_invincibility(enable: bool):
	set_deferred("monitorable", not enable)

func hit_by(spell_info: Dictionary, given_position: Vector2):
	emit_signal("hit_by", spell_info, given_position)
	if hit_sound.playing == false:
		hit_sound.play()
		print("playing!", self, hit_sound)

func _on_AudioStreamPlayer2D_finished():
	hit_sound.stop()
	print("stopping!", self, hit_sound)
