extends Node

func _ready():
	AudioManager.play_bgm(AudioManager.BGM.MENU, -10.0)


func _on_btn_level_1_pressed():
	print("按鈕：前往第一關")
	GameManager.load_specific_level(0)


func _on_btn_level_2_pressed():
	print("按鈕：前往第二關")
	GameManager.load_specific_level(1)

func _on_btn_level_3_pressed():
	print("按鈕：前往第三關")
	GameManager.load_specific_level(2)


func _on_btn_exit_pressed() -> void:
	print("按鈕：離開遊戲")
	get_tree().quit()
