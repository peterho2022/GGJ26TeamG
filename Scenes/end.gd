extends Node

func _ready():
	print("請按 [Space] 鍵回到主選單...")

func _input(event):
	if event.is_action_pressed("ui_select"):
		print("正在返回主選單...")
		GameManager.back_to_menu()
