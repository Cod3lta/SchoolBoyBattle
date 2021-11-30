extends Candy

class_name PeanutLarge, "res://assets/candy/peanut-big.png"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 10
	sprite_frame = load("res://src/actors/candy/types/peanutLarge.tres")
	set_candy_sprite_frame(sprite_frame)
