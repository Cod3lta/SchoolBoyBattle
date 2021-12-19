extends Control

onready var tween = $HBoxContainer/Tween
onready var progress_bar = $HBoxContainer/ProgressBar

func update_progressbar(points: Dictionary):
	$HBoxContainer/LabelRed.set_text(str(points['red']))
	$HBoxContainer/LabelBlack.set_text(str(points['black']))
	
	# Div by zero protection
	if points['red'] == 0 and points['black'] == 0:
		points['red'] = 1
		points['black'] = 1
	
	var old_value = progress_bar.value
	var new_value = float(points['red']) / (float(points['red'] + points['black']))
	
	tween.interpolate_property(
		progress_bar, "value", old_value, new_value, 0.5, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	#$HBoxContainer/ProgressBar.set_value(ratio)
	tween.start()


func _on_ProgressBar_value_changed(value):
	var width = $HBoxContainer/ProgressBar.rect_size.x
	$HBoxContainer/ProgressBar/Particles2D.position.x = value * width
