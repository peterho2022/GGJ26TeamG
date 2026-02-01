extends Node2D

@export var tape_texture: Texture2D  # 在編輯器中拖入你的膠帶貼圖
@export var canvas: Node2D

@export var tape_texture_left_padding: Texture2D

@onready var hand_start = $HandStart
@onready var hand_end: Sprite2D = %HandEnd

var current_tape: NinePatchRect = null
var current_tape_left_padding: NinePatchRect = null
var hand_anchor: Control = null
var tape_height := 120: set = set_tape_height
var temp_tape_height := 0
var end_tape_direction := 0

func _ready():
	hand_start.visible = false
	remove_child(hand_end)
	#HAND_END.visible = false
	#current_tape.add_child(HAND_END)

func set_tape_height(value):
	temp_tape_height = tape_height
	tape_height = value
	if current_tape:
		current_tape.size.y = tape_height
		current_tape.pivot_offset = Vector2(0, tape_height / 2.0)
	#var temp = tape_height - temp_tape_height
	#if temp > 0:
		#end_tape_direction = 1
	#elif temp < 0:
		#end_tape_direction = -1
	#else:
		#end_tape_direction = 0
		
# 1. 選擇初始點：建立實例並固定位置
func place_start_point(pos: Vector2):
	current_tape = NinePatchRect.new()
	current_tape.texture = tape_texture
	
	# to occulude right hand but show left hand
	current_tape.z_index = 50
	current_tape.z_as_relative = false
	
	# 設定 NinePatch 的邊界，確保縮放時兩頭不變形 (數值依貼圖而定)
	current_tape.patch_margin_left = 50
	current_tape.patch_margin_right = 50
	
	current_tape.patch_margin_left = 50
	
	# 設定中心點 (Pivot) 為左側中心
	# 假設膠帶寬度預設為 40
	current_tape.size = Vector2(0, tape_height)
	current_tape.pivot_offset = Vector2(0, tape_height / 2.0)
	
	# 放置位置
	var rot = current_tape.rotation
	var right = Vector2(cos(rot), sin(rot))
	var up = Vector2(-sin(rot), cos(rot))
	
	current_tape.position = get_global_mouse_position() - up * tape_height / 2
	add_child(current_tape)
	
	current_tape_left_padding = NinePatchRect.new()
	current_tape_left_padding.texture = tape_texture_left_padding
	current_tape_left_padding.size = Vector2(150, tape_height)
	current_tape_left_padding.pivot_offset = Vector2(0, tape_height / 2.0)
	current_tape_left_padding.position = right * -50
	current_tape.add_child(current_tape_left_padding)
	
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

		if canvas.current_dir.length() > 0.01:
			current_tape.rotation = canvas.current_dir.angle()
			hand_start.rotation = canvas.current_dir.angle()
	
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

func clear_last_tape():
	var c := get_child_count()
	if c > 0:
		if get_child(c - 1) is NinePatchRect:
			get_child(c - 1).queue_free()
