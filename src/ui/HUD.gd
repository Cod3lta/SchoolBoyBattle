extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func btn_move_pressed(direction, pressed):
	var ev = InputEventAction.new()
	ev.action = direction
	ev.pressed = pressed
	Input.parse_input_event(ev)


func _on_ButtonUp_button_down():
	btn_move_pressed("up", true)


func _on_ButtonRight_button_down():
	btn_move_pressed("right", true)


func _on_ButtonDown_button_down():
	btn_move_pressed("down", true)


func _on_ButtonLeft_button_down():
	btn_move_pressed("left", true)


func _on_ButtonUp_button_up():
	btn_move_pressed("up", false)


func _on_ButtonRight_button_up():
	btn_move_pressed("right", false)


func _on_ButtonDown_button_up():
	btn_move_pressed("down", false)


func _on_ButtonLeft_button_up():
	btn_move_pressed("left", false)
