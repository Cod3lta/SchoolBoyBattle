extends VBoxContainer

signal set_menu(path, direction)

onready var players_list = $GridContainer/VBoxContainer/ItemList
onready var start_button = $GridContainer/VBoxContainer2/ButtonStart

func _ready():
	Gamestate.connect("player_list_changed", self, "refresh_waiting_room")
	Gamestate.connect("game_error", self, "on_game_error")
	refresh_waiting_room()
	
	if get_tree().is_network_server():
		$Label.text += " sur l'adresse " + str(IP.get_local_addresses()[0])
	

func _on_ButtonBack_pressed():
	get_tree().network_peer = null
	emit_signal("set_menu", "res://src/ui/menus/choose-join-local/chooseJoinLocal.tscn", Vector2.LEFT)


func refresh_waiting_room():
	var players = Gamestate.get_players_list()
	players_list.clear()
	for id in players:
		var p = players[id]
		if id == get_tree().get_network_unique_id():
			p += " (You)"
		players_list.add_item(p)

	if get_tree().is_network_server():
		if players.size() < Database.MIN_PLAYERS:
			start_button.text = "Encore " + str(Database.MIN_PLAYERS - players.size()) + " joueur"
			start_button.disabled = true
		else:
			start_button.text = "Démarrer la partie"
			start_button.disabled = false
	else:
		start_button.hide()


func _on_ButtonStart_pressed():
	Gamestate.begin_game()


func on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_exclusive = true
	$ErrorDialog.popup_centered_minsize()


func _on_ErrorDialog_popup_hide():
	emit_signal("set_menu", "res://src/ui/menus/choose-join-local/chooseJoinLocal.tscn", Vector2.LEFT)
