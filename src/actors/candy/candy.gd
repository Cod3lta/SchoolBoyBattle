extends Node2D

class_name Candy, "res://assets/candy/candy-icon.svg"

"""########################################
				VARIABLES
########################################"""


var taken_by: KinematicBody2D = null
var spawner: Node = null

var targeted_position: Vector2 = Vector2.ZERO
puppet var puppet_targeted_pos = Vector2.ZERO

var points: int = 0
var sprite_frame: SpriteFrames = null


"""########################################
				INIT
########################################"""


func _init():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	self.puppet_targeted_pos = self.targeted_position 

func set_candy_sprite_frame(sprite_frame: SpriteFrames):
	$AnimatedSprite.set_sprite_frames(self.sprite_frame)


"""########################################
				PROCESS
########################################"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_network_master():
		if taken_by != null:
			assert(get_tree().is_network_server())
			rset("puppet_targeted_pos", targeted_position)
	else:
		self.targeted_position  = self.puppet_targeted_pos
		
	self.position = lerp(self.position, self.targeted_position, 0.1)


# Picked up / stolen by a player
func _on_Area2D_body_entered(player):
	if not player is KinematicBody2D: return
		
	assert(get_tree().is_network_server())
	
	if $Area2D.get_collision_mask_bit(0):
		# Picked up from the ground
		self.set_collision_player(false) # Doesn't detect every player anymore
		self.spawner.candy_taken() # Free the spawner for
	
	player.take_candy(self)


"""########################################
				MISC
########################################"""


func is_taken():
	return self.taken_by != null


func set_collision_player(value: bool):
	$Area2D.set_collision_mask_bit(0, value)


# false -> red   /   true -> black
func set_color_team(is_black: bool):
	# Set the candy visual color
	pass


# false -> red   /   true -> black
func set_collision_team(is_black: bool):
	$Area2D.set_collision_mask_bit(3, not is_black)
	$Area2D.set_collision_mask_bit(4, is_black)

func delete():
	assert(is_network_master())
	for id in gamestate.get_clients_list():
		rpc_id(id, "delete_candy_client", self.get_name())
	delete_candy_client(self.get_name())
	

remote func delete_candy_client(candy_name):
	self.queue_free()
