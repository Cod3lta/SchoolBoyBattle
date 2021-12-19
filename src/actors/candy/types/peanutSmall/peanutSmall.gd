extends Candy

class_name PeanutSmall, "res://assets/candy/peanut-small.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 1
	sprite_frame = preload("res://src/actors/candy/types/peanutSmall/peanutSmall.tres")
	explosion_material = preload("res://src/actors/candy/types/peanutSmall/explosionPeanutSmall.tres")
	set_candy_type_properties()
