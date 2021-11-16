extends Node2D


const PLAYER_LINE_DISTANCE_DRAW = 100
const DISTANCE_BETWEEN_CANDIES = 120


# Called when the node enters the scene tree for the first time.
func init(players_node: Node2D):
	var players = gamestate.get_players_list()
	
	for p in players_node.get_children():
		var id = p.get_name()
		
		var line_2d = Line2D.new()
		line_2d.set_name(str(id))
		line_2d.set_default_color(Color(1, 1, 1, 0))
		add_child(line_2d)
		line_2d.add_point(p.get_position())
		line_2d.add_point(p.get_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var players = get_tree().get_root().get_node("Game/YSort/Players")
	# Create the lines behind the players
	self.draw_lines(players)
	
	# Place the candies
	self.place_candies(players)
	

func draw_lines(players):
	for p in players.get_children():
		var id = p.get_name()
		var line = self.get_node(id)
		
		var last_last_point = line.points[1]
		line.set_point_position(0, p.position)
		if not line.points.empty():
			if p.position.distance_to(last_last_point) > PLAYER_LINE_DISTANCE_DRAW:
				line.add_point(p.position, 0)


func place_candies(players):
	for p in players.get_children():
		var trail: Line2D = get_tree().get_root().get_node("Game/Trails/" + p.get_name())
		
		# the remaining length on the trail until the next candy
		var remaining_dist: int = self.DISTANCE_BETWEEN_CANDIES
		 # the index of the current point in on the player's trail
		var i: int = 0
		var segment_lengh = distance_between_trail_points(trail, i)
		
		for c in p.trail: # for each candy the player has picked up
			while remaining_dist > segment_lengh:
				remaining_dist -= segment_lengh
				i += 1
				segment_lengh = distance_between_trail_points(trail, i)
			# place the candy somewhere in this segment of the line
			var factor = remaining_dist / segment_lengh
			
			c.targeted_position = lerp(trail.points[i], trail.points[i+1], factor)
			
			# calculate the remaining distance for the next candy to place
			remaining_dist = self.DISTANCE_BETWEEN_CANDIES + remaining_dist


# Returns the distance between the points i and i+1
func distance_between_trail_points(trail: Line2D, i: int) -> float :
	return sqrt(
		pow(trail.points[i].x - trail.points[i+1].x, 2) + 
		pow(trail.points[i].y - trail.points[i+1].y, 2)
		)
