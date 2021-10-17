extends Control

signal use_move_vector(move_vector)

var move_vector = Vector2.ZERO
var speed_factor = 0
var joystick_active = false
var button_center

onready var touch_screen_button = $TouchScreenButton
onready var sprite = $Sprite

func _ready():
	button_center = Vector2(
		touch_screen_button.normal.get_width()/2 * touch_screen_button.scale.x,
		touch_screen_button.normal.get_height()/2 * touch_screen_button.scale.y
		)

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var joystick_screen_position = touch_screen_button.get_global_transform_with_canvas().origin
		var pos = event.position - joystick_screen_position
		if touch_screen_button.is_pressed():
			move_vector = calculate_move_vector(pos)
			joystick_active = true
			set_sprite_position(pos - button_center)
			sprite.visible = true
	if event is InputEventScreenTouch and not event.is_pressed():
			joystick_active = false
			sprite.position = touch_screen_button.position + button_center
			emit_signal("use_move_vector", Vector2.ZERO)

func _physics_process(delta):
	if joystick_active:
		emit_signal("use_move_vector", move_vector)

func calculate_move_vector(pos):
	var speed_vector = ((pos - button_center) / button_center * 2) as Vector2
	speed_factor = min(speed_vector.length(), 1)
	return (pos - button_center).normalized() * speed_factor

func set_sprite_position(pos):
	var angle = atan2(pos.y, pos.x)
	var sprite_pos = Vector2(
		button_center.x + cos(angle) * button_center.x / 2 * speed_factor,
		button_center.y + sin(angle) * button_center.y / 2 * speed_factor
		)
	sprite.position = sprite_pos
	
