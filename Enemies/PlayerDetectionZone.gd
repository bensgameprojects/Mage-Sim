extends Area2D

var player = null

func can_see_player():
	return player != null

# found a player
func _on_PlayerDetectionZone_body_entered(body):
	player = body

# lost the player
func _on_PlayerDetectionZone_body_exited(_body):
	player = null
