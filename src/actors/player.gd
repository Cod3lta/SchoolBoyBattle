extends KinematicBody2D

"""########################################
				VARIABLES
########################################"""

# Declare member variables here.
enum gender_e {BOY=0, GIRL=1}
enum team_e {RED=0, BLACK=1}


var velocity = Vector2.ZERO
var joystick_velocity = Vector2.ZERO

var speed = 500
var gender = null
var team = null
var flip_h = false

"""########################################
				INIT
########################################"""

func _init():
	self.gender = gender_e.GIRL
	self.team = team_e.RED


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
	# set the velocity to zero
	velocity = Vector2.ZERO
	
	run()
	
	# The function already uses delta in its implementation
	var collision = move_and_slide(velocity) 
	
	
	animate()
	

"""########################################
				MOVEMENT
########################################"""


func run():
	# Between -1 and 1
	# var player_input = get_player_action_input()
	var player_input = joystick_velocity
	
	velocity += player_input
	# velocity = velocity.normalized() * speed
	velocity *= speed


func get_player_action_input():
	# Controlled with WASD
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	

"""########################################
				ANIMATIONS
########################################"""


func animate():
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


"""########################################
				SLOTS
########################################"""


func _on_joystick_event(move_vector):
	joystick_velocity = move_vector
