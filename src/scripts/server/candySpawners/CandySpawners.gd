extends Node


var spawners = Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(spawners_list: Array):
	for s in spawners_list:
		self.spawners.append(s)


func _on_Timer_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var available_spawners: Array = Array()
	for s in self.spawners:
		if not s.spawned:
			available_spawners.append(s)
	
	if available_spawners.size() == 0:
		return
	
	var spawner:Position2D = available_spawners[randi() % available_spawners.size()]
	spawner.server_spawn()
