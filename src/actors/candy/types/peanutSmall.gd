extends Candy

class_name PeanutSmall, "res://assets/candy/peanut-small.png"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 1
	sprite_frame = load("res://src/actors/candy/types/peanutSmall.tres")
	set_candy_sprite_frame(sprite_frame)
