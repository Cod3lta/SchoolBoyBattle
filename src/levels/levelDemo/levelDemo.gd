extends YSort

signal player_arrived_at_home


func _on_ZoneRed_body_entered(body):
	if not get_tree().is_network_server(): return
	if not body is Player: return
	if not body.team == Player.team_e.RED: return
	
	emit_signal("player_arrived_at_home", body)


func _on_ZoneBlack_body_entered(body):
	if not get_tree().is_network_server(): return
	if not body is Player: return
	if not body.team == Player.team_e.BLACK: return
	
	emit_signal("player_arrived_at_home", body)
