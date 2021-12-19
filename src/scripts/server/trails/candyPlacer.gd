extends Node

# Place the candies on the line (based on the parameters in the Database
# singleton) and returns the candies that are offsetting in the beginnning
# of the line
func place(trail: Line2D, candies: Array, offset = 0) -> Array:
	# the remaining length on the trail until the next candy
	var remaining_dist: int = Database.DISTANCE_BETWEEN_CANDIES + offset
	 # the index of the current point in on the player's trail
	var i: int = 0
	var segment_lengh = distance_between_trail_points(trail, i)
	var end_of_trail: bool = false
	
	var offsetting_candies = Array()
	
	for c in candies: # for each candy the player has picked up
		while remaining_dist > segment_lengh and not end_of_trail:
			remaining_dist -= segment_lengh
			if trail.points.size()-1 < i+2:
				end_of_trail = true
			else:
				i += 1
				segment_lengh = distance_between_trail_points(trail, i)
		
		# place the candy somewhere in this segment of the line
		
		# div by zero protection
		if segment_lengh == 0:
			segment_lengh = 1
		var factor = remaining_dist / segment_lengh
		if end_of_trail: factor = 1
		
		# If the candy is too much before the trail, it's considered as being
		# at home
		if factor < -5.0: 
			offsetting_candies.append(c)
			
		
		c.targeted_position = lerp(trail.points[i], trail.points[i+1], factor)
		
		# calculate the remaining distance for the next candy to place
		remaining_dist = Database.DISTANCE_BETWEEN_CANDIES + remaining_dist
		
	return offsetting_candies


# Returns the distance between the points i and i+1
func distance_between_trail_points(trail: Line2D, i: int) -> float :
	return sqrt(
		pow(trail.points[i].x - trail.points[i+1].x, 2) + 
		pow(trail.points[i].y - trail.points[i+1].y, 2)
		)
