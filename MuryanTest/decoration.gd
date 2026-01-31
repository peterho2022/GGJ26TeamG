extends Node2D

# 引用場景中的 TapeManager
@export var tape_manager: Node2D
@export var canvas: Node2D
var tape_is_finished: bool = false

var last_length = 0

func _ready() -> void:
	canvas.start_tape.connect(func(pos:Vector2):
		tape_manager.tape_height = canvas.tape_width_px
		tape_manager.show_hand_start()
		tape_manager.place_start_point(pos)
		tape_is_finished = false
		GameManager.tape_start()
		)
	canvas.change_tape_length.connect(func(length):
		tape_manager.current_tape.size.x = length
		last_length = length
		)
	canvas.end_tape.connect(func():
		tape_is_finished = true
		tape_manager.remove_hand_end()
		tape_manager.hide_hand_start()
		GameManager.tape_end(last_length)
		)
	canvas.commit_finished.connect(func():
		tape_manager.clear_tape()
		GameManager.commit_tape()
		)
func _process(delta: float) -> void:
	if not tape_is_finished:
		tape_manager.set_direction()
