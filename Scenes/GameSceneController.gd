extends Node2D

@export var totalTime : float = 99
@export var colorLayers : Array[Color]

@export var countdownTimer : CountdownTimer
@export var color_palette : ColorPaletteController
@export var end_scene : EndScene
@export var main : Node2D

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
	
	countdownTimer.on_timeout.connect(_on_timeout)
	
	AudioManager.play_bgm(AudioManager.BGM.GAME, -10.0)

func _on_tape_start():
	AudioManager.play_sfx(AudioManager.SFX.TAPE_RIP)
	pass

func _on_tape_end():
	AudioManager.play_sfx(AudioManager.SFX.TAPE_PASTE)
	pass

func _on_timeout():	
	_show_end_scene()

func _on_commit_tape():
	current_index += 1
	if current_index < len(colorLayers):
		color_palette.next_color()
		AudioManager.play_sfx(AudioManager.SFX.PAINT)
	else:
		_show_end_scene()

func _show_end_scene():
	GameManager.game_over = true
	countdownTimer.visible = false
	end_scene.setup()
	end_scene.visible = true
	AudioManager.stop_all()
	AudioManager.play_bgm(AudioManager.BGM.END)
