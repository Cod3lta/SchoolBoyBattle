extends Line2D

var candies := Array()
var offset := 0
var speed := 25

func _process(delta):
	offset -= speed
	var candies_at_home: Array = CandyPlacer.place(self, candies, offset)
	
	# Remove the candies that are at home
	for c in candies_at_home:
		c = c as Candy
		candies.erase(c)
		c.delete()
		offset += Database.DISTANCE_BETWEEN_CANDIES
	
	if candies.size() == 0:
		queue_free()
	
