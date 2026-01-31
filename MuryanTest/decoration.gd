extends Node2D

# 引用場景中的 TapeManager
@export var tape_manager: Node2D
@export var canvas: Node2D

func _ready() -> void:
	canvas.start_tape.connect(func(pos:Vector2):
		tape_manager.place_start_point(pos)
		)
	canvas.change_tape_length.connect(func(length):
		tape_manager.current_tape.size.x = length
		)
#func _input(event):
	## 偵測滑鼠左鍵點擊
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#var mouse_pos = tape_manager.get_global_mouse_position()
				#

#func _process(_delta):
	#var mouse_pos = tape_manager.get_global_mouse_position()
	#tape_manager.set_length(canvas.current_end_local)
	# 持續更新視覺預覽
	#if current_state == TestState.CHOOSING_DIR:
		#tape_manager.set_direction(mouse_pos)
	#elif current_state == TestState.CHOOSING_LEN:
		#tape_manager.set_length(canvas.end_local)
