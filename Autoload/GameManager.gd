extends Node

var level_list: Array[String] = [
	"res://Scenes/GameScene.tscn",
	"res://Scenes/GameScene.tscn",
	"res://Scenes/GameScene.tscn",
]

signal on_tape_start
signal on_tape_end
signal on_commit_tape

# 固定場景的路徑 (先填好你的選單和結局路徑)
var menu_scene_path: String = "res://Scenes/MenuScene.tscn" 
var end_scene_path: String = "res://Scenes/EndScene.tscn"

# --- 內部變數 ---
var current_level_index: int = 0

var total_tape_length: float = 0
var game_over : bool = false

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
	game_over = false
	current_level_index = 0
	reset_tape_length()
	get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn") # 範例路徑

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
	
func load_specific_level(index: int):
	# 安全檢查：確保 index 沒有超出陣列範圍
	if index >= 0 and index < level_list.size():
		current_level_index = index # 更新目前的進度變數
		_change_scene_safe(level_list[index]) # 載入該關卡
	else:
		print("錯誤：關卡索引超出範圍！")

func add_tape_length(v: float):
	total_tape_length += v
	
func reset_tape_length():
	total_tape_length = 0.0

func tape_start():
	on_tape_start.emit()

func tape_end(length):
	total_tape_length += length
	print('total_tape_length = ', total_tape_length)
	on_tape_end.emit()
	
func commit_tape():
	on_commit_tape.emit()
	AudioManager.play_sfx(AudioManager.SFX.PAINT)
