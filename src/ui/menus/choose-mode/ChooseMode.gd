extends VBoxContainer

signal set_menu(path)


func _on_ButtonBack_pressed():
	emit_signal("set_menu", "res://src/ui/menus/home/Home.tscn", Vector2.UP)


func _on_ButtonLocal_pressed():
	emit_signal("set_menu", "res://src/ui/menus/choose-join-local/chooseJoinLocal.tscn", Vector2.RIGHT)
