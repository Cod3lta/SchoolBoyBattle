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
	init_client(players_init)
	
	if get_tree().is_network_server():
		self.init_server()
	
	if gamestate.get_server_only():
		$CameraServerOnly.visible = true
		$CameraServerOnly.current = true
		$CanvasLayer/HUD.visible = false


func init_client(players_init: Dictionary):
	var player_scene = load("res://src/actors/player/player.tscn")
	var i_black = 0
	var i_red = 0
	
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


func init_server():
	# Candy spawners
	var candy_spawner = load("res://src/scripts/server/candySpawners/CandySpawners.tscn").instance()
	self.add_child(candy_spawner)
	candy_spawner.init($YSort/Map/CandySpawners.get_children())
	
	# Candy trails
	var trails = load("res://src/scripts/server/trails/Trails.tscn").instance()
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


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		


"""########################################
				PROCESS
########################################"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if get_tree().is_network_server():
		pass # self.draw_player_trail()


remote func spawn_candy(pos, type):
	pass


"""########################################
				SLOTS
########################################"""

# Only called on the server
func add_points(player: Player):
	assert(get_tree().is_network_server())
	
	var team: bool = player.team
	var points: int = player.points_in_queue()
	
	print(player.team)
	match (player.team):
		player.team_e.RED: self.points['red'] += points
		player.team_e.BLACK: self.points['black'] += points
	
	for id in gamestate.get_clients_list():
		rpc_id(id, "update_progressbar_client", self.points)
	
	emit_signal("update_progressbar", self.points)

remote func update_progressbar_client(points: Dictionary):
	emit_signal("update_progressbar", points)
