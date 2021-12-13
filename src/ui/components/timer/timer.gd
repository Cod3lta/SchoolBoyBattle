extends Control


var time_left := 0

func set_time(wait_time):
	time_left = wait_time
	$SecTimer.start(1)
	_on_SecTimer_timeout()


func _on_SecTimer_timeout():
	time_left -= 1
	
	$Label.set_text("%d:%02d" % [
		time_left % 3600 / 60, 
		time_left % 60,
	])
