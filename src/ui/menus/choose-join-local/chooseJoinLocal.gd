extends Menu

onready var ip_address = $PopupIpAdress/VBoxContainer/HBoxContainer/LineEdit
onready var error_label = $PopupIpAdress/VBoxContainer/Error


func _ready():
	Gamestate.connect("connection_succeeded", self, "on_connection_success")


func _on_ButtonBack_pressed():
	emit_signal("set_menu", "res://src/ui/menus/choose-mode/ChooseMode.tscn", Vector2.LEFT)


func _on_ButtonOpenPopup_pressed():
	$PopupIpAdress.popup(Rect2(0, 0, get_viewport_rect().size.x, get_viewport_rect().size.y))
	ip_address.grab_focus()


func _on_ButtonCreateServer_pressed():
	Gamestate.host_and_play_game()
	emit_signal("set_menu", "res://src/ui/menus/waiting-room/WaitingRoom.tscn", Vector2.RIGHT)


func _on_ButtonJoinServer_pressed():
	if not ip_address.text.is_valid_ip_address():
		error_label.text = "L'adresse IP est invalide"
		return

	error_label.text = ""
	Gamestate.join_game(ip_address.text)


func on_connection_success():
	emit_signal("set_menu", "res://src/ui/menus/waiting-room/WaitingRoom.tscn", Vector2.RIGHT)


func _on_ButtonHostOnly_pressed():
	Gamestate.host_game()
	emit_signal("set_menu", "res://src/ui/menus/waiting-room/WaitingRoom.tscn", Vector2.RIGHT)
