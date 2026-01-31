extends Node
func _input(event):
	# 按下 Enter 開始遊戲
	if event.is_action_pressed("ui_select"): 
		print("呼叫 Start Game")
		GameManager.start_game()
