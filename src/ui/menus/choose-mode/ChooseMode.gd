extends Menu

func _ready():
	if Database.get_player_name() != "":
		$HBoxContainer/ButtonSetPseudo.text = Database.get_player_name()

func _on_ButtonBack_pressed():
	emit_signal("set_menu", "res://src/ui/menus/home/Home.tscn", Vector2.UP)


func _on_ButtonLocal_pressed():
	emit_signal("set_menu", "res://src/ui/menus/choose-join-local/chooseJoinLocal.tscn", Vector2.RIGHT)


func _on_ButtonSetPseudo_pressed():
	emit_signal("set_menu", "res://src/ui/menus/set-player-name/setPlayerName.tscn", Vector2.UP)
