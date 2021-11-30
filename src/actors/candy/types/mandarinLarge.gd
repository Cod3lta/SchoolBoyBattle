extends Candy

class_name MandarinLarge, "res://assets/candy/mandarin-big.png"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 15
	sprite_frame = load("res://src/actors/candy/types/mandarinLarge.tres")
	set_candy_sprite_frame(sprite_frame)
