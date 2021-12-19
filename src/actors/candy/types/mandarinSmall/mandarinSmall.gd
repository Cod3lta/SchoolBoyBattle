extends Candy

class_name MandarinSmall, "res://assets/candy/mandarin-small.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 5
	sprite_frame = preload("res://src/actors/candy/types/mandarinSmall/mandarinSmall.tres")
	explosion_material = preload("res://src/actors/candy/types/mandarinSmall/explosionMandarinSmall.tres")
	set_candy_type_properties()
	
