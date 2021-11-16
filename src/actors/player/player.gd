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

var trail: Array = Array()

var speed = 500
var gender = null
var team = null
var flip_h = false

"""########################################
				INIT
########################################"""


# Default values
func _init():
	self.gender = gender_e.GIRL
	self.team = team_e.RED

# Used as a constructor
func init(name: String, gender: bool, team: bool, position: Vector2):
	$NameTag.set_text(name)
	self.gender = gender
	self.team = team
	self.position = position


# Called when the node enters the scene tree for the first time
func _ready():
	self.init_sprite_frame()


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
	if not is_network_master():
		puppet_pos = position # To avoid jitter


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
	$AnimatedSprite.animation = get_animation()
	$AnimatedSprite.flip_h = self.flip_h
	if abs(self.velocity.x) > 0:
		self.flip_h = self.velocity.x < 0


func init_sprite_frame():
	var sprite_frames: SpriteFrames
	if int(self.gender) == self.gender_e.BOY  and int(self.team) == self.team_e.RED:
		sprite_frames = preload("res://src/actors/player/spriteFrames/boyRed.tres")
	if int(self.gender) == self.gender_e.BOY  and int(self.team) == self.team_e.BLACK:
		sprite_frames = preload("res://src/actors/player/spriteFrames/boyBlack.tres")
	if int(self.gender) == self.gender_e.GIRL and int(self.team) == self.team_e.RED:
		sprite_frames = preload("res://src/actors/player/spriteFrames/girlRed.tres")
	if int(self.gender) == self.gender_e.GIRL and int(self.team) == self.team_e.BLACK:
		sprite_frames = preload("res://src/actors/player/spriteFrames/girlBlack.tres")
	$AnimatedSprite.set_sprite_frames(sprite_frames)


func get_animation():
	if abs(self.velocity.x) > 0 || abs(self.velocity.y) > 0:
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
				CANDIES
########################################"""


func take_candy(candy: Node2D):
	assert(candy is Node2D)
	self.trail.insert(0, candy)
	candy.set_collision_team(bool(self.team))
	candy.set_color_team(bool(self.team))


"""########################################
				SLOTS
########################################"""


func _on_joystick_event(move_vector):
	joystick_velocity = move_vector
