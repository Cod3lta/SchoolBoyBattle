extends Position2D


export var spawned: bool = false
var candy_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	self.candy_scene = preload("res://src/actors/candy/candy.tscn")


# Called only server-side
func server_spawn():
	assert(get_tree().is_network_server())
	
	self.spawned = true
	for id in gamestate.get_players_list():
		rpc_id(id, "spawn_candy")
	
	self.spawn_candy()


# Canned on every client
remote func spawn_candy():
	var candy: Node2D = self.candy_scene.instance()
	candy.set_network_master(1)
	#if get_tree().is_network_server():
	#	candy.position = self.position
	#else:
	candy.targeted_position = self.position
	candy.position = self.position
	
	
	if get_tree().is_network_server():
		candy.spawner = self
		candy.set_collision_player(true)
	
	get_node("../../../Candies").add_child(candy)
