extends Node2D


@export var tape_texture: Texture2D  # 在編輯器中拖入你的膠帶貼圖


@onready var hand_start = $HandStart
@onready var hand_end: ColorRect = %HandEnd

var current_tape: NinePatchRect = null
var hand_anchor: Control = null
var tape_height := 40

func _ready():
	hand_start.visible = false
	remove_child(hand_end)
	#HAND_END.visible = false
	#current_tape.add_child(HAND_END)

# 1. 選擇初始點：建立實例並固定位置
func place_start_point(pos: Vector2):
	current_tape = NinePatchRect.new()
	current_tape.texture = tape_texture
	
	# 設定 NinePatch 的邊界，確保縮放時兩頭不變形 (數值依貼圖而定)
	current_tape.patch_margin_left = 16
	current_tape.patch_margin_right = 16
	
	# 設定中心點 (Pivot) 為左側中心
	# 假設膠帶寬度預設為 40
	current_tape.size = Vector2(0, tape_height)
	current_tape.pivot_offset = Vector2(0, tape_height / 2.0)
	
	# 放置位置
	current_tape.position = pos
	add_child(current_tape)
	hand_anchor = Control.new()
	current_tape.add_child(hand_anchor)
	hand_anchor.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	hand_anchor.add_child(hand_end)
	
	hand_start.global_position = pos
	hand_start.visible = true
	
func set_direction():
	var target_pos = get_global_mouse_position()
	if current_tape:
		# 計算起點到目前滑鼠的角度
		var angle = current_tape.position.angle_to_point(target_pos)
		current_tape.rotation = angle
		

# 3. 選擇長度：固定方向，僅拉伸長度
func set_length(target_pos: Vector2):
	#hand_end.visible = true
	if current_tape:
		# 使用點積 (Dot Product) 計算滑鼠在膠帶前進方向上的投影長度
		# 這樣就算滑鼠偏移了，膠帶長度也會鎖定在那個角度上
		var direction_vec = Vector2.RIGHT.rotated(current_tape.rotation)
		var offset = target_pos - current_tape.position
		var length = offset.dot(direction_vec)
		
		var end_pos = current_tape.position + (direction_vec * current_tape.size.x)
		# 5. 更新手的位置 (如果要讓手心對準末端，記得減去手自己的 pivot_offset)
		#hand_end.global_position = end_pos
		
		# 長度不能為負數
		current_tape.size.x = max(0, length)

func tape_end():
	hand_start.visible = false
	#hand_end.visible = false

func remove_hand_end():
	hand_end.get_parent().remove_child(hand_end)

func hide_hand_start():
	hand_start.hide()
	
func show_hand_start():
	hand_start.show()
	
func clear_tape():
	for tape in get_children():
		if tape is NinePatchRect:
			tape.queue_free()
