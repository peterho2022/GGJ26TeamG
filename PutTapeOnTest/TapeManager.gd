extends Node2D

@export var tape_texture: Texture2D  # 在編輯器中拖入你的膠帶貼圖
var current_tape: NinePatchRect = null

# 1. 選擇初始點：建立實例並固定位置
func place_start_point(pos: Vector2):
	current_tape = NinePatchRect.new()
	current_tape.texture = tape_texture
	
	# 設定 NinePatch 的邊界，確保縮放時兩頭不變形 (數值依貼圖而定)
	current_tape.patch_margin_left = 16
	current_tape.patch_margin_right = 16
	
	# 設定中心點 (Pivot) 為左側中心
	# 假設膠帶寬度預設為 40
	var tape_height = 40 
	current_tape.size = Vector2(0, tape_height)
	current_tape.pivot_offset = Vector2(0, tape_height / 2.0)
	
	# 放置位置
	current_tape.position = pos
	add_child(current_tape)

# 2. 選擇方向：根據滑鼠位置旋轉膠帶
func set_direction(target_pos: Vector2):
	if current_tape:
		# 計算起點到目前滑鼠的角度
		var angle = current_tape.position.angle_to_point(target_pos)
		current_tape.rotation = angle
		
		# 預覽：為了讓玩家知道方向，可以先給一點點長度
		current_tape.size.x = 10

# 3. 選擇長度：固定方向，僅拉伸長度
func set_length(target_pos: Vector2):
	if current_tape:
		# 使用點積 (Dot Product) 計算滑鼠在膠帶前進方向上的投影長度
		# 這樣就算滑鼠偏移了，膠帶長度也會鎖定在那個角度上
		var direction_vec = Vector2.RIGHT.rotated(current_tape.rotation)
		var offset = target_pos - current_tape.position
		var length = offset.dot(direction_vec)
		
		# 長度不能為負數
		current_tape.size.x = max(0, length)
