extends Position2D

class_name Spawner

export var spawned := false
var candy_scene := preload("res://src/actors/candy/candy.tscn")


remote func spawn_candy(type: String):
	var candy = self.candy_scene.instance()
	
	# candy parameters
	candy.init(self.position, type)
	
	if get_tree().is_network_server():
		candy.spawner = self
		# candy.set_collision_player(true)
	
	get_node("../../../Candies").add_child(candy)


func candy_taken():
	self.spawned = false
