extends Node

# 引用場景中的 TapeManager
@onready var tape_manager = $"../ShowHandTap"

# 定義測試狀態
enum TestState { IDLE, CHOOSING_DIR, CHOOSING_LEN }
var current_state = TestState.IDLE

func _input(event):
	# 偵測滑鼠左鍵點擊
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = tape_manager.get_global_mouse_position()
		
		match current_state:
			TestState.IDLE:
				# 第一步：呼叫起始點函數
				print("測試：設定初始點")
				tape_manager.place_start_point(mouse_pos)
				current_state = TestState.CHOOSING_DIR
				
			TestState.CHOOSING_DIR:
				# 第二步：點擊第二次，進入長度選擇
				print("測試：方向已選定，開始拉長度")
				current_state = TestState.CHOOSING_LEN
				
			TestState.CHOOSING_LEN:
				# 第三步：點擊第三次，完成放置
				print("測試：長度已選定，膠帶放置完成")
				tape_manager.set_length(mouse_pos)
				# tape_manager.hide_hands() # 如果你有寫隱藏手的函數
				current_state = TestState.IDLE

func _process(_delta):
	var mouse_pos = tape_manager.get_global_mouse_position()
	
	# 持續更新視覺預覽
	if current_state == TestState.CHOOSING_DIR:
		tape_manager.set_direction(mouse_pos)
	elif current_state == TestState.CHOOSING_LEN:
		tape_manager.set_length(mouse_pos)
