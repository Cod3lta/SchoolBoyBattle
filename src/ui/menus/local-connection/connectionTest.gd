extends Control


onready var players_list = 		$WaitingRoom/MarginContainer/VBoxContainer/PlayersList
onready var show_ip_address = 	$WaitingRoom/MarginContainer/VBoxContainer/IPAddress
onready var start_button = 		$WaitingRoom/MarginContainer/VBoxContainer/HBoxContainer/ButtonStart
onready var back_button = 		$WaitingRoom/MarginContainer/VBoxContainer/HBoxContainer/ButtonBack

onready var join_button = 		$Connection/MarginContainer/VBoxContainer/GridContainer/ButtonJoin
onready var host_button = 		$Connection/MarginContainer/VBoxContainer/GridContainer/ButtonHost
onready var username = 			$Connection/MarginContainer/VBoxContainer/GridContainer/LineEditPseudo
onready var ip_address = 		$Connection/MarginContainer/VBoxContainer/GridContainer/LineEditAddress
onready var error = 			$Connection/MarginContainer/VBoxContainer/LabelError

const MIN_PLAYERS = 1

func _ready():
	Gamestate.connect("connection_failed", self, "_on_connection_failed")
	Gamestate.connect("connection_succeeded", self, "_on_connection_success")
	Gamestate.connect("player_list_changed", self, "refresh_waiting_room")
	Gamestate.connect("game_error", self, "_on_game_error")
	
	$Connection.show()
	$WaitingRoom.hide()
	
	# Show the IP address on the GUI
	show_ip_address.text = "Adresse IP : " + str(IP.get_local_addresses()[0])
	
	# Set the username
	if OS.has_environment("USERNAME"):
		username.text = OS.get_environment("USERNAME")
	else:
		username.text = "Username"


func _on_ButtonHost_pressed():
	$WaitingRoom.show()
	$Connection.hide()
	Gamestate.host_and_play_game(username.text)
	refresh_waiting_room()


func _on_ButtonHostOnly_pressed():
	$WaitingRoom.show()
	$Connection.hide()
	Gamestate.host_game()
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

	Gamestate.join_game(ip_address.text, username.text)


func _on_ButtonStart_pressed():
	Gamestate.begin_game()


func _on_ButtonBack_pressed():
	Gamestate.end_game()
	get_tree().network_peer = null
	$Connection.show()
	$WaitingRoom.hide()


func _on_connection_success():
	$Connection.hide()
	$WaitingRoom.show()


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	join_button.disabled = false
	host_button.disabled = false


func refresh_waiting_room():
	var players = Gamestate.get_players_list()
	players_list.clear()
	for id in players:
		var p = players[id]
		if id == get_tree().get_network_unique_id():
			p += " (You)"
		players_list.add_item(p + " (" + str(id) + ")")

	if get_tree().is_network_server():
		if players.size() < MIN_PLAYERS - 1:
			start_button.text = "Encore " + str(MIN_PLAYERS - players.size() - 1) + " joueur"
			start_button.disabled = true
		else:
			start_button.text = "Démarrer la partie"
			start_button.disabled = false
	else:
		start_button.hide()
