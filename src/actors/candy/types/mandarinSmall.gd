extends Candy

class_name MandarinSmall, "res://assets/candy/mandarin-small.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 5
	sprite_frame = load("res://src/actors/candy/types/mandarinSmall.tres")
	set_candy_sprite_frame(sprite_frame)
	
