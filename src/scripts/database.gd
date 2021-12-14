extends Node


"""########################################
				CANDIES
########################################"""

const candies = {
	'peanutSmall': {
		'file': preload("res://src/actors/candy/types/peanutSmall.gd"),
		'chance' : 0.75
	},
	'mandarinSmall': {
		'file': preload("res://src/actors/candy/types/mandarinSmall.gd"),
		'chance' : 0.18
	},
	'peanutLarge': {
		'file': preload("res://src/actors/candy/types/peanutLarge.gd"),
		'chance' : 0.05
	},
	'mandarinLarge': {
		'file': preload("res://src/actors/candy/types/mandarinLarge.gd"),
		'chance' : 0.02
	},
}


"""########################################
				PLAYER
########################################"""

const MIN_PLAYERS = 1
