extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_main_player():
	$CanvasLayer/HUD/Joystick.connect(
		"use_move_vector", 
		get_node("YSort/Players/" + str(get_tree().get_network_unique_id())), 
		"_on_joystick_event"
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
