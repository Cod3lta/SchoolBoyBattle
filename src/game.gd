extends Node2D

class_name Game

"""########################################
				VARIABLES
########################################"""


var player: Player
var is_server: bool

var points = {
	'red': 0,
	'black': 0
}

signal update_progressbar


"""########################################
				INIT
########################################"""


func init(players_init: Dictionary):
	randomize()
	
	init_client(players_init)
	
	if get_tree().is_network_server():
		self.init_server()
	
	if Gamestate.get_server_only():
		$YSort/Map/CameraServerOnly.visible = true
		$YSort/Map/CameraServerOnly.current = true
		$CanvasLayer/HUD.visible = false


"""#####################
Init client
#####################"""


func init_client(players_init: Dictionary):
	var player_scene = load("res://src/actors/player/player.tscn")
	var i_black = 0
	var i_red = 0
	
	# Create every player
	for id in players_init:
		var p_init = players_init[id]
		
		var spawn_pos = Vector2()
		if p_init['team']:
			spawn_pos = get_node("YSort/Map/SpawnPointsBlack/" + str(i_black)).position
			i_black += 1
		else:
			spawn_pos = get_node("YSort/Map/SpawnPointsRed/" + str(i_red)).position
			i_red += 1
		var p = player_scene.instance()
		
		p.init(p_init["name"], p_init["gender"], p_init["team"], spawn_pos)
		p.set_name(str(id)) # Use unique ID as node name
		p.set_network_master(id) #set unique id as master
		
		# If the player we are creating is the one of this instance
		if get_tree().get_network_unique_id() == id:
			# Set it's camera as the main one
			p.get_node("Camera").current = true
			player = p

		get_node("YSort/Players").add_child(p)
	
	self.connect("update_progressbar", $CanvasLayer/HUD/ProgressBar, "update_progressbar")


"""#####################
Init server
#####################"""


func init_server():
	# Candy spawners
	var candy_spawner = load("res://src/scripts/server/candySpawners/candySpawners.tscn").instance()
	self.add_child(candy_spawner)
	candy_spawner.init($YSort/Map/CandySpawners.get_children())
	
	# Candy trails
	var trails = load("res://src/scripts/server/trails/trails.tscn").instance()
	self.add_child(trails)
	trails.init($YSort/Players)
	$YSort/Map.connect("player_arrived_at_home", self, "add_points")
	$YSort/Map.connect("player_arrived_at_home", trails, "clear_trail")

func set_main_player():
	# Connects the joystick's signal to the player of this instance
	$CanvasLayer/HUD/Joystick.connect(
		"use_move_vector", 
		get_node("YSort/Players/" + str(get_tree().get_network_unique_id())), 
		"_on_joystick_event"
	)
		


"""########################################
				START / END GAME
########################################"""


# Called when the node enters the scene tree for the first time.
func _ready():
	play_music()
	$CanvasLayer/HUD/Timer.set_time($GeneralTimer.wait_time)


func play_music():
	pass #$AudioStreamPlayer.play(0)


func _on_GeneralTimer_timeout():
	# Game ended
	get_tree().get_root().add_child(load("res://src/ui/menus/game-ended/gameEnded.tscn").instance())
	get_node("/root/Game").queue_free()


"""########################################
				SLOTS
########################################"""

# Only called on the server
func add_points(player: KinematicBody2D):
	assert(get_tree().is_network_server())
	
	var team: bool = player.team
	var points: int = player.points_in_queue()
	
	match (player.team):
		player.team_e.RED: self.points['red'] += points
		player.team_e.BLACK: self.points['black'] += points
	
	for id in Gamestate.get_clients_list():
		rpc_id(id, "update_progressbar_client", self.points)
	
	emit_signal("update_progressbar", self.points)

remote func update_progressbar_client(points: Dictionary):
	emit_signal("update_progressbar", points)
