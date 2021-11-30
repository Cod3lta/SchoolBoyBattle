extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func update_progressbar(points: Dictionary):
	print(points)
	$LabelRed.set_text(str(points['red']))
	$LabelBlack.set_text(str(points['black']))
	if points['red'] != 0 or points['black'] != 0:
		var ratio: float = float(points['red']) / float(points['red'] + points['black'])
		$ProgressBar.set_value(ratio)
