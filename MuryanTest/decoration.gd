extends Node2D

# 引用場景中的 TapeManager
@export var tape_manager: Node2D
@export var canvas: Node2D
var tape_is_finished: bool = false

func _ready() -> void:
	canvas.start_tape.connect(func(pos:Vector2):
		tape_manager.place_start_point(pos)
		tape_is_finished = false
		)
	canvas.change_tape_length.connect(func(length):
		tape_manager.current_tape.size.x = length
		)
	canvas.end_tape.connect(func():
		tape_is_finished = true
		tape_manager.remove_hand_end()
		)
	
func _process(delta: float) -> void:
	if not tape_is_finished:
		tape_manager.set_direction()
