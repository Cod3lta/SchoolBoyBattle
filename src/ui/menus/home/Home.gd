extends Menu

func _on_ButtonPlay_pressed():
	if Database.player_name == "":
		emit_signal("set_menu", "res://src/ui/menus/set-player-name/setPlayerName.tscn", Vector2.DOWN)
	else:
		emit_signal("set_menu", "res://src/ui/menus/choose-mode/ChooseMode.tscn", Vector2.DOWN)


func _on_PlayersAnimation_animation_finished(anim_name):
	if anim_name == "characters_entering":
		$Characters/PlayersAnimation.play("characters_idle")
