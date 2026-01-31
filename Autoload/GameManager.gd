extends Node

# --- 設定區 ---

# 這是你要填空的地方。目前可以是空的，或是放暫位符。
# 之後你做好了關卡，就把路徑貼進來，例如 "res://scenes/levels/Level1.tscn"
var level_list: Array[String] = [
	"res://Scenes/TestLevel1.tscn",
	"res://Scenes/TestLevel2.tscn",
]

# 固定場景的路徑 (先填好你的選單和結局路徑)
var menu_scene_path: String = "res://Scenes/MenuScene.tscn" 
var end_scene_path: String = "res://Scenes/EndScene.tscn"


# --- 內部變數 ---
var current_level_index: int = 0

# --- 功能函數 ---

# 1. 開始遊戲 (從選單呼叫)
func start_game():
	current_level_index = 0
	_load_current_level()

# 2. 載入下一關 (由關卡終點的觸發器呼叫)
func load_next_level():
	current_level_index += 1
	
	# 檢查是否還有下一關
	if current_level_index < level_list.size():
		_load_current_level()
	else:
		# 沒關卡了，進入結局
		_go_to_end_scene()

# 3. 回到選單 (從結局或暫停選單呼叫)
func back_to_menu():
	current_level_index = 0
	_change_scene_safe(menu_scene_path)

# --- 核心邏輯 (包含安全檢查) ---

func _load_current_level():  
	# 防呆機制：如果陣列是空的 (你還沒做關卡時)
	if level_list.is_empty():
		print("警告: 尚未設定任何關卡路徑！")
		return

	var path = level_list[current_level_index]
	_change_scene_safe(path)

func _go_to_end_scene():
	_change_scene_safe(end_scene_path)

# 統一處理換場景，順便檢查檔案存不存在
func _change_scene_safe(path: String):
	print("正在模擬切換到場景: ", path) 
	get_tree().change_scene_to_file(path)
