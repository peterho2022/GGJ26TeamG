extends Node2D

# 引用場景中的 TapeManager
@export var tape_manager: Node2D
@export var canvas: Node2D
var tape_is_finished: bool = false
var tape_is_started: bool = false

var last_length = 0

func _ready() -> void:
	canvas.start_tape.connect(func(pos:Vector2):
		tape_manager.tape_height = canvas.tape_width_px
		tape_manager.show_hand_start()
		tape_manager.place_start_point(pos, get_global_mouse_position())
		tape_is_finished = false
		tape_is_started = true
		GameManager.tape_start()
		)
	canvas.change_tape_length.connect(func(length):
		tape_manager.current_tape.size.x = length
		last_length = length
		)
	canvas.end_tape.connect(func():
		tape_is_finished = true
		tape_is_started = false
		tape_manager.remove_hand_end()
		tape_manager.hide_hand_start()
		#var tween := create_tween()
		#tween.set_ease(Tween.EASE_IN_OUT)
		#tween.set_trans(Tween.TRANS_QUART)
		#tween.tween_property(tape_manager.current_tape, "position:y", tape_manager.current_tape.position.y - tape_manager.tape_height/2.0 * tape_manager.end_tape_direction * 0.8, 0.3)
		GameManager.tape_end(last_length)
		)
	canvas.commit_finished.connect(func():
		tape_manager.clear_tape()
		GameManager.commit_tape()
		)
	canvas.change_tape_size.connect(func(width):
		if not tape_is_started:
			return
		tape_is_finished = true
		var pos = tape_manager.hand_start.global_position
		tape_manager.remove_hand_end()
		tape_manager.hide_hand_start()
		tape_manager.clear_last_tape()
		tape_manager.tape_height = width
		tape_manager.place_start_point(pos, pos)
		tape_is_finished = false
	)
	
func _process(delta: float) -> void:
	if GameManager.game_over:
		return
	if not tape_is_finished and tape_manager:
		tape_manager.set_direction()
	
