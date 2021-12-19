extends Node2D

const collector_scene: Resource = preload("res://src/scripts/server/trails/collector.tscn")


"""########################################
				INIT
########################################"""


# Called when the node enters the scene tree for the first time.
func init(players_node: Node2D):
	var players = Gamestate.get_players_list()
	
	for p in players_node.get_children():
		var id = p.get_name()
		
		var line_2d = Line2D.new()
		line_2d.set_name(str(id))
		line_2d.set_default_color(Color(1, 1, 1, 0.0))
		add_child(line_2d)
		line_2d.add_point(p.get_position())
		line_2d.add_point(p.get_position())


"""########################################
				PROCESS
########################################"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var players = get_tree().get_root().get_node("Game/YSort/Players")
	
	# Create the lines behind the players
	self.place_trails(players)
	
	# Place the candies
	self.place_candies(players)


"""########################################
				PLAYER TRAILS
########################################"""
	

func place_trails(players):
	for p in players.get_children():
		var id = p.get_name()
		var line = self.get_node(id)
		
		var last_last_point = line.points[1]
		line.set_point_position(0, p.position)
		if not line.points.empty():
			if p.position.distance_to(last_last_point) > Database.PLAYER_LINE_DISTANCE_DRAW:
				line.add_point(p.position, 0)


"""########################################
				PLACE CANDIES
########################################"""


func place_candies(players):
	for p in players.get_children():
		var trail: Line2D = get_tree().get_root().get_node("Game/Trails/" + p.get_name())
		var candies: Array = p.trail
		
		CandyPlacer.place(trail, candies)


"""########################################
				SLOTS
########################################"""


func animate_candies_collect(player: Player):
	assert(get_tree().is_network_server())
	var line_2d: Line2D = get_node(player.get_name())
	
	var collector: Line2D = collector_scene.instance()
	collector.candies = player.trail.duplicate(true)
	collector.points = line_2d.points
	collector.set_name("Collect" + player.get_name().capitalize())
	$Collecting.add_child(collector)
	
	# Reset the player's line
	line_2d.clear_points()
	line_2d.add_point(player.get_position())
	line_2d.add_point(player.get_position())
	
	# Clear the player's candies trail
	player.trail.clear()
