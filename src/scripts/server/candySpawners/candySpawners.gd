extends Node


var spawners = Array()


func init(spawners_list: Array):
	for s in spawners_list:
		self.spawners.append(s)


func _on_Timer_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Build a list of the available spawners (the one that are empty)
	var available_spawners: Array = Array()
	for s in self.spawners:
		if not s.spawned:
			available_spawners.append(s)
	
	if available_spawners.size() == 0: return
	
	# Choose a random spawner and a candy type
	var spawner:Position2D = available_spawners[randi() % available_spawners.size()]
	var type: String = get_random_candy_type()
	
	spawner.spawned = true
	
	for id in Gamestate.get_clients_list():
		spawner.rpc_id(id, "spawn_candy", type)
	spawner.spawn_candy(type)


func get_random_candy_type() -> String:
	var chances: Array = [0]
	var sum :float = 0
	for type in Database.candies.values():
		chances.push_back(sum + type['chance'])
		sum += type['chance']
	
	var val = rand_range(0, sum)
	
	for i in range(chances.size() - 1):
		if val > chances[i] and val < chances[i+1]:
			return Database.candies.keys()[i]
	
	return Database.candies.keys()[0]
	
	
	
	
