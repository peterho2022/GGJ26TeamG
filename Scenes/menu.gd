extends Node
func _input(event):
	# 按下 Enter 開始遊戲
	if event.is_action_pressed("ui_select"): 
		print("呼叫 Start Game")
		GameManager.start_game()


func _on_btn_level_1_pressed():
	print("按鈕：前往第一關")
	GameManager.load_specific_level(0)


func _on_btn_level_2_pressed():
	print("按鈕：前往第二關")
	GameManager.load_specific_level(1)


func _on_btn_exit_pressed() -> void:
	print("按鈕：離開遊戲")
	get_tree().quit()
