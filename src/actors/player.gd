extends KinematicBody2D

"""########################################
				VARIABLES
########################################"""

# Declare member variables here.
enum gender_e {BOY=0, GIRL=1}
enum team_e {RED=0, BLACK=1}

puppet var puppet_pos = Vector2.ZERO
puppet var puppet_velocity = Vector2.ZERO

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

func init(name: String, gender: bool, team: bool, position: Vector2):
	$NameTag.set_text(name)
	self.gender = gender
	self.team = team
	self.position = position

func init_animated_sprite():
	for sprite in $Sprites.get_children():
		var sprite_as = sprite as AnimatedSprite
		sprite_as.hide()
	get_sprite_node().show()


# Called when the node enters the scene tree for the first time
func _ready():
	init_animated_sprite()

"""########################################
				PROCESS
########################################"""

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	
	# Calculate the movements
	run()
	
	multiplayer_movements()
	apply_movements()
	
	animate()
	

"""########################################
				MOVEMENT
########################################"""


func apply_movements():
	# The function already uses delta in its implementation
	move_and_slide(velocity)


func run():
	# Between -1 and 1
	velocity = joystick_velocity # Input from the joystick
	# velocity = get_player_action_input() # Input from WASD keys
	
	# No need to normalize velocity, because the speed can vary depending
	# on the joystick's input
	velocity *= speed


# Here to replace the joystick if necessary
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
	var node_to_animate = get_sprite_node()
	node_to_animate.animation = get_animation()
	node_to_animate.flip_h = flip_h
	if abs(velocity.x) > 0:
		flip_h = velocity.x < 0


func get_sprite_node():
	if int(gender) == gender_e.BOY  and int(team) == team_e.RED:   return $Sprites/BoyRed
	if int(gender) == gender_e.BOY  and int(team) == team_e.BLACK: return $Sprites/BoyBlack
	if int(gender) == gender_e.GIRL and int(team) == team_e.RED:   return $Sprites/GirlRed
	if int(gender) == gender_e.GIRL and int(team) == team_e.BLACK: return $Sprites/GirlBlack
	print("No animation defined")
	assert(false)

func get_animation():
	if abs(velocity.x) > 0 || abs(velocity.y) > 0:
		return "run"
	return "idle"


"""########################################
				MULTIPLAYER
########################################"""


func multiplayer_movements():
	if is_network_master():
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_velocity

"""########################################
				SLOTS
########################################"""


func _on_joystick_event(move_vector):
	joystick_velocity = move_vector
