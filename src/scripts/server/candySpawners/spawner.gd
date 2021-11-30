extends Position2D

class_name Spawner

export var spawned: bool = false
var candy_scene: Resource

var types = [
	preload("res://src/actors/candy/types/mandarinLarge.gd"),
	preload("res://src/actors/candy/types/mandarinSmall.gd"),
	preload("res://src/actors/candy/types/peanutLarge.gd"),
	preload("res://src/actors/candy/types/peanutSmall.gd")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.candy_scene = preload("res://src/actors/candy/candy.tscn")


# Called only server-side
func server_spawn():
	assert(get_tree().is_network_server())
	
	var candy_type: int = randi() % types.size()
	
	self.spawned = true
	for id in gamestate.get_clients_list():
		rpc_id(id, "spawn_candy", candy_type)
	
	self.spawn_candy(candy_type)


# Called on every client
remote func spawn_candy(candy_type: int):
	var candy = self.candy_scene.instance()
	candy.set_script(types[candy_type])
	candy.set_network_master(1)
	
	candy.targeted_position = self.position
	candy.position = self.position
	
	if get_tree().is_network_server():
		candy.spawner = self
		candy.set_collision_player(true)
	
	get_node("../../../Candies").add_child(candy)


func candy_taken():
	self.spawned = false
