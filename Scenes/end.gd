extends Node

func _ready():
	print("請按 [Space] 鍵回到主選單...")

func _on_button_pressed() -> void:
	print("按鈕：回到主選單")
	GameManager.back_to_menu()
