extends Menu

func _ready():
	$HBoxContainer2/LineEdit.text = Database.get_player_name()
	$HBoxContainer2/LineEdit.grab_focus()

func _on_ButtonNext_pressed():
	if $HBoxContainer2/LineEdit.text == "":
		return
	
	Database.player_name = $HBoxContainer2/LineEdit.text
	emit_signal("set_menu", "res://src/ui/menus/choose-mode/ChooseMode.tscn", Vector2.DOWN)
