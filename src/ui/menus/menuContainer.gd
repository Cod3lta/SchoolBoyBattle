extends Control

onready var current_menu = $MarginContainer/.get_child(0)
var old_menu = null

var transition_vector = Vector2.ZERO

const TRANSITION_LENGTH = 0.2
const TRANSITION_VECTOR_LENGTH = 30

func _ready():
	connect_current_menu()

# path : the path to the new menu to display
# direction : the direction of the transition to the new menu
# parameters : parameters that will be passed to the new menu's instance
func set_menu(path: String, direction: Vector2 = Vector2(0, 1), parameters: Array = []):
	old_menu = current_menu
	current_menu = load(path).instance()
	
	if current_menu.has_method("init") and not parameters.empty():
		current_menu.init(parameters)
	
	transition_vector = direction * TRANSITION_VECTOR_LENGTH
	animate_transition()
	
# Animate the old menu disappearing
func animate_transition():
	if old_menu.is_queued_for_deletion():
		current_menu.modulate.a = 0.0
		current_menu.connect("ready", $TimerTransition, "start")
		$MarginContainer.add_child(current_menu)
		return
	
	var tween_old_menu: Tween = get_node("TransitionOldMenu")
	# Animate position
	tween_old_menu.interpolate_property(
		old_menu, "rect_position", old_menu.get_position(), old_menu.get_position() - transition_vector, 
		TRANSITION_LENGTH, Tween.TRANS_CUBIC, Tween.EASE_IN)
	
	# Animate opacity
	tween_old_menu.interpolate_property(
		old_menu, "modulate:a", modulate.a, 0.0, 
		TRANSITION_LENGTH, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween_old_menu.start()


# Animate the new menu appearing
func _on_TransitionOldMenu_tween_all_completed():
	old_menu.queue_free()
	current_menu.modulate.a = 0.0
	current_menu.connect("ready", $TimerTransition, "start")
	$MarginContainer.add_child(current_menu)


func play_second_animation():
	# Animate position
	var tween_new_menu = get_node("TransitionNewMenu")
	tween_new_menu.interpolate_property(
		current_menu, "rect_position",
		current_menu.get_position() + transition_vector, current_menu.get_position(),
		TRANSITION_LENGTH, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	# Animate opacity
	tween_new_menu.interpolate_property(
		current_menu, "modulate:a", 
		0.0, 1.0,
		TRANSITION_LENGTH, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	
	tween_new_menu.start()
	

# When all the animations are done
func _on_TransitionNewMenu_tween_all_completed():
	connect_current_menu()


func connect_current_menu():
	current_menu.connect("set_menu", self, "set_menu")
