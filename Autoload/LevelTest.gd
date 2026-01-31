extends Node

func _ready():
	# 這裡會顯示現在是第幾關 (index 從 0 開始，所以 +1 比較好閱讀)
	print("載入成功！目前關卡索引：", GameManager.current_level_index)

func _input(event):
	# 按下空白鍵模擬 "抵達終點"
	if event.is_action_pressed("ui_select"): # Space鍵
		print("模擬過關！呼叫下一關...")
		GameManager.load_next_level()
 	
