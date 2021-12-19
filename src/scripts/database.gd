extends Node


"""########################################
				CANDIES
########################################"""

const candies = {
	'peanutSmall': {
		'file': preload("res://src/actors/candy/types/peanutSmall/peanutSmall.gd"),
		'chance' : 0.75
	},
	'mandarinSmall': {
		'file': preload("res://src/actors/candy/types/mandarinSmall/mandarinSmall.gd"),
		'chance' : 0.18
	},
	'peanutLarge': {
		'file': preload("res://src/actors/candy/types/peanutLarge/peanutLarge.gd"),
		'chance' : 0.05
	},
	'mandarinLarge': {
		'file': preload("res://src/actors/candy/types/mandarinLarge/mandarinLarge.gd"),
		'chance' : 0.02
	},
}


const PLAYER_LINE_DISTANCE_DRAW = 100
const DISTANCE_BETWEEN_CANDIES = 120


"""########################################
				PLAYER
########################################"""


const MIN_PLAYERS = 1
var player_name = ""

func get_player_name():
	if player_name == "":
		return "username"
	return player_name


"""########################################
				DEVICE MEMORY
########################################"""


# Save data on the device
func save_points():
	pass
