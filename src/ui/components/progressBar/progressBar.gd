extends Control


func update_progressbar(points: Dictionary):
	$HBoxContainer/LabelRed.set_text(str(points['red']))
	$HBoxContainer/LabelBlack.set_text(str(points['black']))
	if points['red'] != 0 or points['black'] != 0:
		var ratio: float = float(points['red']) / float(points['red'] + points['black'])
		$HBoxContainer/ProgressBar.set_value(ratio)


func _on_ProgressBar_value_changed(value):
	var width = $HBoxContainer/ProgressBar.rect_size.x
	$HBoxContainer/ProgressBar/Particles2D.position.x = value * width
