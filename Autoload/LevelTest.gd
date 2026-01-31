extends Node

# 取得 CanvasLayer 下的 Label
@onready var debug_label = $CanvasLayer/DebugLabel

func _ready():
	print("載入成功！目前關卡索引：", GameManager.current_level_index)
	update_debug_display()

func _input(event):
	# 只有在按鈕 "剛按下" 的那一瞬間觸發 (避免按住不放一直觸發)
	if not event.is_pressed():
		return

	# --- 1. 過關邏輯 (Space 空白鍵) ---
	if event.is_action_pressed("ui_select"):
		print("模擬過關！呼叫下一關...")
		GameManager.load_next_level()
		
	# --- 2. 作弊加分 (T 鍵) ---
	# 這裡只需要寫一次就好
	elif event is InputEventKey and event.keycode == KEY_T:
		GameManager.add_tape_length(3.0) # 統一增加 3.0
		print("作弊成功！增加 3.0m")
		update_debug_display()
		
	# --- 3. 重置分數 (R 鍵) ---
	elif event is InputEventKey and event.keycode == KEY_R:
		GameManager.reset_tape_length() 
		print("重置分數")
		update_debug_display()

# 更新畫面顯示的小工具
func update_debug_display():
	if debug_label:
		debug_label.text = "目前累積模擬膠帶: " + str(GameManager.total_tape_length) + " m"
		
		# 顯示評價預測
		var temp_rank = GameManager.calculate_rank()
		debug_label.text += "\n當前預估評價: " + temp_rank
