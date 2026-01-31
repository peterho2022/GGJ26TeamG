extends Node2D

@export var totalTime : float = 99
@export var colorLayers : Array[Color]

@export var countdownTimer : CountdownTimer
@export var color_palette : ColorPaletteController
@export var end_scene : EndScene

var canvas : Canvas
var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.on_tape_start.connect(_on_tape_start)
	GameManager.on_tape_end.connect(_on_tape_end)
	GameManager.on_commit_tape.connect(_on_commit_tape)
	
	color_palette.setup(colorLayers)
	countdownTimer.start(totalTime)
	
	canvas = $Main/Canvas
	canvas.current_color_array = colorLayers
	
	current_index = 0

func _on_tape_start():
	pass

func _on_tape_end():
	pass

func _on_commit_tape():
	current_index += 1
	if current_index < len(colorLayers):
		color_palette.next_color()
	else:
		countdownTimer.visible = false
		end_scene.setup()
		end_scene.visible = true
	pass
