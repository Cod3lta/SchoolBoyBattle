extends Menu



func _ready():
	pass

func init(parameters):
	show_game_results(parameters)

remote func show_game_results(parameters):
	var boss_red = $VBoxContainer/HBoxContainer/BossRed
	var boss_black = $VBoxContainer/HBoxContainer/BossBlack
	var label_win = $VBoxContainer/LabelWinner
	var results_list = $VBoxContainer/HBoxContainer/VBoxContainer/ItemList
	
	var team_winner = parameters[0]
	var points_by_player = parameters[1]
	
	# The winner team
	match(team_winner):
		0: # Red team won the game
			label_win.set_text("St-Nicolas a gagné !")
			label_win.align = Label.ALIGN_LEFT
			boss_black.set_visible(false)
		1: # Black team won the game
			label_win.set_text("Père Fouettard a gagné !")
			label_win.align = Label.ALIGN_RIGHT
			boss_red.set_visible(false)
		-1: # Ex-aeco
			label_win.set_text("Ex-aeco !")
	
	# The players result
	for p in points_by_player.values():
		results_list.add_item(p["name"] + " : " + str(p["points"]))

func _on_ButtonBack_pressed():
	emit_signal("set_menu", "res://src/ui/menus/choose-mode/ChooseMode.tscn", Vector2.LEFT)
