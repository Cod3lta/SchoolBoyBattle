extends Node2D


enum TYPE_E {NICOLAS=0, FOUETTARD=1}

export(int, "St Nicolas", "Pere Fouettard") var type = TYPE_E.NICOLAS


# Called when the node enters the scene tree for the first time.
func _ready():
	var sprite_frames: SpriteFrames
	
	if type == TYPE_E.FOUETTARD:
		sprite_frames = preload("res://src/actors/boss/spriteFrames/pereFouettard.tres")
	elif type == TYPE_E.NICOLAS:
		sprite_frames = preload("res://src/actors/boss/spriteFrames/stNicolas.tres")
	$AnimatedSprite.set_sprite_frames(sprite_frames)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
