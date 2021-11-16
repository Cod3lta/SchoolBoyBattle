extends Node2D

"""########################################
				VARIABLES
########################################"""


var taken_by: KinematicBody2D = null
var spawner: Node = null

var targeted_position: Vector2 = Vector2.ZERO

puppet var puppet_targeted_pos = Vector2.ZERO


"""########################################
				INIT
########################################"""


func _init():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	self.puppet_targeted_pos = self.targeted_position


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


# Picked up from the ground by a player
func _on_Area2D_body_entered(player):
	if not player is KinematicBody2D:
		return
	
	assert(get_tree().is_network_server())
	
	self.set_collision_player(false) # Doesn't detect every player
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
