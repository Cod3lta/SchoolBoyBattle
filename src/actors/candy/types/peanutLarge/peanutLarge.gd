extends Candy

class_name PeanutLarge, "res://assets/candy/peanut-big.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 10
	sprite_frame = preload("res://src/actors/candy/types/peanutLarge/peanutLarge.tres")
	explosion_material = preload("res://src/actors/candy/types/peanutLarge/explosionPeanutLarge.tres")
	set_candy_type_properties()
