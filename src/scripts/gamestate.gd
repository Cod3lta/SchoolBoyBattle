extends Node

# This file is used as an autoloaded singleton.
# If something happens with the connection, this file will emit signals
# informing the other scenes about the events

"""#################################################
				VARIABLES
#################################################"""

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 8

# Name for my player.
var player_name = "no player name yet"

# Names for remote players in id:name format.
var other_players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)



"""#################################################
				INIT
#################################################"""

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


"""#################################################
				EVERY INSTANCE
#################################################"""


"""#####################
Player management
#####################"""

# Callback from SceneTree.
func _player_connected(id):
	# When a player connects to the server we are already connected on, this slot is activated
	# We have to tell the newly connected player that we are here.
	# -> This signal is also emitted server-side when a new clients made a connection
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + other_players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	other_players[id] = new_player_name
	print("A new player is connected : " + str(id))
	emit_signal("player_list_changed")


func unregister_player(id):
	other_players.erase(id)
	emit_signal("player_list_changed")


"""#####################
Start / stop game
#####################"""


remote func pre_start_game(players_init):
	print(players_init)

	var game = load("res://src/Game.tscn").instance()
	get_tree().get_root().add_child(game)
	# Hide the LocalConnection node (not remove it)
	get_tree().get_root().get_node("LocalConnection").hide()
	
	var player_scene = load("res://src/actors/player.tscn")
	
	# Create the players
	var i = 0
	for id in players_init:
		var p_init = players_init[id]
		var spawn_pos = game.get_node("SpawnPoints/" + str(i)).position
		var p = player_scene.instance()
		
		p.init(p_init["name"], p_init["gender"], p_init["team"], spawn_pos)
		p.set_name(str(id)) # Use unique ID as node name
		p.set_network_master(id) #set unique id as master
		
		# If the player we are creating is the one of this instance
		if get_tree().get_network_unique_id() == id:
			# Set it's camera as the main one
			p.get_node("Camera").current = true

		game.get_node("YSort/Players").add_child(p)		
		i += 1

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start")
	elif other_players.size() == 0:
		# If we're the server and no one else is connected
		post_start_game()


remote func post_start_game():
	var game = get_node("/root/Game")
	game.set_main_player()
	get_tree().set_pause(false) # Unpause and unleash the game!


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	other_players.clear()


"""#####################
Getters and setters
#####################"""


func get_player_list():
	return other_players.values()


func get_player_name():
	return player_name


"""#################################################
				THIS INSTANCE AS A CLIENT
#################################################"""
	

func join_game(ip, new_player_name):
	player_name = new_player_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server§
	emit_signal("connection_succeeded")
	print("We are connected!")
	print(get_tree().get_network_connected_peers())


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


"""#################################################
				THIS INSTANCE AS THE SERVER
#################################################"""


# This instance clicked the "host" button
func host_game(new_player_name):
	player_name = new_player_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)


# Called by a client to tell the server he's ready
remote func ready_to_start():
	assert(get_tree().is_network_server())

	var id = get_tree().get_rpc_sender_id()
	if not id in players_ready:
		players_ready.append(id)
	# Wait for every player to be ready
	if players_ready.size() == other_players.size():
		# If everyone is ready
		for p in other_players:
			rpc_id(p, "post_start_game")
		post_start_game()


# This instance (the server) pressed on the button "START"
func begin_game():
	assert(get_tree().is_network_server())
	
	randomize()
	var team_toggler = randf() > 0.5
	
	# setup teams and player genders
	var all_players = other_players.duplicate(false)
	all_players[1] = player_name
	var players_init = {}
	
	for id in all_players:
		players_init[id] = {
			"name": all_players[id],
			"gender": randf() > 0.5,
			"team": team_toggler
		}
		team_toggler = not team_toggler

	# tell everyone to get ready
	for p in all_players:
		rpc_id(p, "pre_start_game", players_init)

	pre_start_game(players_init)

