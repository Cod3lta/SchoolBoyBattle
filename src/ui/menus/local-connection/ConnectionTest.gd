extends Control


onready var players_list = $WaitingRoom/MarginContainer/VBoxContainer/PlayersList
onready var start_button = $WaitingRoom/MarginContainer/VBoxContainer/HBoxContainer/ButtonStart
onready var host_button = $Connection/VBoxContainer/GridContainer/ButtonHost
onready var join_button = $Connection/VBoxContainer/GridContainer/ButtonJoin
onready var username = $Connection/VBoxContainer/GridContainer/LineEditPseudo
onready var ip_address = $Connection/VBoxContainer/GridContainer/LineEditAddress
onready var error = $Connection/VBoxContainer/LabelError
onready var back_button = $WaitingRoom/MarginContainer/VBoxContainer/HBoxContainer/ButtonBack

const MIN_PLAYERS = 1

func _ready():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_waiting_room")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	$Connection.show()
	$WaitingRoom.hide()
	# Set the username
	if OS.has_environment("USERNAME"):
		username.text = OS.get_environment("USERNAME")
	else:
		username.text = "Username"


func _on_ButtonHost_pressed():
	$WaitingRoom.show()
	$Connection.hide()
	gamestate.host_game(username.text)
	refresh_waiting_room()


func _on_ButtonJoin_pressed():
	if username.text == "":
		error.text = "Le nom est invalide"
		return

	if not ip_address.text.is_valid_ip_address():
		error.text = "L'adresse IP est invalide"
		return

	error.text = ""
	host_button.disabled = true
	join_button.disabled = true

	gamestate.join_game(ip_address.text, username.text)


func _on_ButtonStart_pressed():
	gamestate.begin_game()


func _on_ButtonBack_pressed():
	gamestate.end_game()
	get_tree().network_peer = null
	$Connection.show()
	$WaitingRoom.hide()


func _on_connection_success():
	$Connection.hide()
	$WaitingRoom.show()

func _on_game_ended():
	show()
	$Connection.show()
	$WaitingRoom.hide()
	join_button.disabled = false
	host_button.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	join_button.disabled = false
	host_button.disabled = false


func refresh_waiting_room():
	var players = gamestate.get_player_list()
	players.sort()
	players_list.clear()
	players_list.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		players_list.add_item(p)

	if get_tree().is_network_server():
		if players.size() < MIN_PLAYERS - 1:
			start_button.text = "Encore " + str(MIN_PLAYERS - players.size() - 1) + " joueur"
			start_button.disabled = true
		else:
			start_button.text = "Démarrer la partie"
			start_button.disabled = false
	else:
		start_button.hide()
