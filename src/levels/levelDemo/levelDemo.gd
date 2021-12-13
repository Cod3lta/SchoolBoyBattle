extends YSort

signal player_arrived_at_home


func _on_home_body_entered(body):
	if not get_tree().is_network_server(): return
	if not body is Player: return
	
	emit_signal("player_arrived_at_home", body)

