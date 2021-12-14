extends Area2D

class_name Candy

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

func init(pos: Vector2, type: String):
	# FIXME : the game crashed if I remove the "self." in these lines??
	self.set_script(Database.candies[type].file)
	self.targeted_position = pos
	self.position = pos


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_network_master(1)
	set_process(false)

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
			rset_unreliable("puppet_targeted_pos", targeted_position)
	else:
		self.targeted_position  = self.puppet_targeted_pos
	self.position = lerp(self.position, self.targeted_position, 0.1)


remote func client_take():
	self.set_process(true)


func take(player: KinematicBody2D):
	assert(get_tree().is_network_server())
	
	self.taken_by = player
	self.set_process(true)
	
	if get_collision_layer_bit(1):
		# picked up from the ground
		# Change the collision layer bits
		set_collision_layer_bit(1, false) # remove the candy layer
		self.spawner.candy_taken()
	
	if player.team:
		# Player is team black
		set_collision_layer_bit(4, true) # add the candy black layer
	else:
		# Player is team red
		set_collision_layer_bit(3, true) # add the candy red layer


"""########################################
				MISC
########################################"""


func is_taken():
	return self.taken_by != null


#func set_collision_player(value: bool):
#	$Area2D.set_collision_mask_bit(0, value)


remote func set_color_team(is_black: bool):
	if is_black:
		self.modulate = Color("6d6d6d")
	else:
		self.modulate = Color("ae3838")


# false -> red   /   true -> black

func set_collision_team(is_black: bool):
	$Area2D.set_collision_layer_bit(3, not is_black)
	$Area2D.set_collision_layer_bit(4, is_black)

func delete():
	assert(is_network_master())
	for id in Gamestate.get_clients_list():
		rpc_id(id, "delete_candy_client", self.get_name())
	delete_candy_client(self.get_name())
	

remote func delete_candy_client(candy_name):
	self.queue_free()
