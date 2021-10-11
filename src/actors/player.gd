extends Node2D

"""########################################
				VARIABLES
########################################"""

# Declare member variables here.
enum gender_e {BOY=0, GIRL=1}
enum team_e {RED=0, BLACK=1}


var velocity = Vector2.ZERO
var speed = 500
var gender = null
var team = null
var flip_h = false
var current_animation = "idle"

"""########################################
				INIT
########################################"""

func _init():
	self.gender = gender_e.BOY
	self.team = team_e.BLACK


func init_animated_sprite():
	for sprite in $Sprites.get_children():
		var sprite_as = sprite as AnimatedSprite
		sprite_as.hide()
	get_sprite_node().show()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	init_animated_sprite()

"""########################################
				PROCESS
########################################"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	run()
	animate()
	position += velocity * delta


func run():
	var player_input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var player_input_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity.x = player_input_x
	velocity.y = player_input_y 
	velocity = velocity.normalized() * speed


"""########################################
				ANIMATIONS
########################################"""


func animate():
	current_animation = get_animation()
	var node = str(self.gender) + '_' + str(self.team)
	var animated_node = get_sprite_node()
	animated_node.animation = get_animation()
	animated_node.flip_h = flip_h
	if abs(velocity.x) > 0:
		flip_h = velocity.x < 0


func get_sprite_node():
	if gender == gender_e.BOY  and team == team_e.RED:   return $Sprites/BoyRed
	if gender == gender_e.BOY  and team == team_e.BLACK: return $Sprites/BoyBlack
	if gender == gender_e.GIRL and team == team_e.RED:   return $Sprites/GirlRed
	if gender == gender_e.GIRL and team == team_e.BLACK: return $Sprites/GirlBlack
	print("No animation defined")
	assert(false)

func get_animation():
	if abs(velocity.x) > 0 || abs(velocity.y) > 0:
		return "run"
	return "idle"
