extends KinematicBody2D

class_name Player

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

var player_name := ""
var points_earned := 0
var speed := 500
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
func init(name: String, gender: bool, team: int, position: Vector2):
	$NameTag.set_text(name)
	self.gender = gender
	self.team = team
	self.position = position
	self.player_name = name


# Called when the node enters the scene tree for the first time
func _ready():
	self.init_sprite_frame()
	
	if get_tree().is_network_server():
		$CandiesCollider.set_collision_mask_bit(1, true)
		if team:
			# Team is black, the player will also detect red candies
			$CandiesCollider.set_collision_mask_bit(3, true)
		else:
			# Team is red, the player will also detect black candies
			$CandiesCollider.set_collision_mask_bit(4, true)
	
	# Hide the nametag of the player we're playing
	if is_network_master():
		$NameTag.visible = false
	


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


func animate():
	$AnimatedSprite.animation = get_animation()
	$AnimatedSprite.flip_h = self.flip_h
	if abs(self.velocity.x) > 0:
		self.flip_h = self.velocity.x < 0
	# footsteps particles
	$Footsteps.emitting = self.velocity.length() > 0


func get_animation():
	if self.velocity.length() > 0:
		return "run"
	return "idle"


"""########################################
				MULTIPLAYER
########################################"""


func multiplayer_movements():
	if is_network_master():
		# TODO : don't send the position and velocity in every frame
		rset_unreliable("puppet_velocity", velocity) # used for the puppet's animations
		rset_unreliable("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_velocity


"""########################################
				CANDIES
########################################"""

func _on_CandiesCollider_area_entered(candy: Area2D):
	if not get_tree().is_network_server(): return
	if not candy is Candy: return
	
	var candies_to_append = Array()
	
	if candy.taken_by == null:
		candies_to_append.append(candy)
	else:
		candies_to_append = self.steal_candies(candy)
	
	candies_to_append.invert()
	
	for c in candies_to_append:
		self.trail.insert(0, c)
		
		# Tell the client instances of this candy that it needs to be activated
		for id in Gamestate.get_clients_list():
			c.rpc_id(id, "client_take")
		
		c.take(self)
		
		# Set the candy's color
		for id in Gamestate.get_clients_list():
			c.rpc_id(id, "set_color_team", bool(self.team))
		c.set_color_team(bool(self.team))


func steal_candies(candy: Node2D) -> Array:
	if not get_tree().is_network_server():
		return Array()
	return candy.taken_by.loose_candies(candy)


func loose_candies(from: Node2D) -> Array:
	var i_start: int = trail.find(from)
	if i_start == -1: return Array()
	
	var stolen_candies = self.trail.slice(i_start, self.trail.size())
	self.trail.resize(i_start)
	
	return stolen_candies


func arrive_at_home():
	pass

func points_in_queue() -> int:
	var points: int = 0
	for c in self.trail:
		points += c.points
	return points


"""########################################
				SLOTS
########################################"""


func _on_joystick_event(move_vector):
	joystick_velocity = move_vector
