extends Candy

class_name MandarinLarge, "res://assets/candy/mandarin-big.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 15
	sprite_frame = preload("res://src/actors/candy/types/mandarinLarge/mandarinLarge.tres")
	explosion_material = preload("res://src/actors/candy/types/mandarinLarge/explosionMandarinLarge.tres")
	set_candy_type_properties()
