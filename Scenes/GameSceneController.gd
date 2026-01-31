extends Node2D

@export var totalTime1 : float = 99
@export var colorLayers1 : Array[Color]
@export var scoreRange1 : Array[float] = [ 5000, 7000, 10000, 14000 ]
@export var refImage1 : Texture2D

@export var totalTime2 : float = 99
@export var colorLayers2 : Array[Color]
@export var scoreRange2 : Array[float] = [ 5000, 7000, 10000, 14000 ]
@export var refImage2 : Texture2D

@export var totalTime3 : float = 99
@export var colorLayers3 : Array[Color]
@export var scoreRange3 : Array[float] = [ 5000, 7000, 10000, 14000 ]
@export var refImage3 : Texture2D

@export var countdownTimer : CountdownTimer
@export var color_palette : ColorPaletteController
@export var end_scene : EndScene
@export var main : Node2D
@export var ReferenceImage : Sprite2D

var canvas : Canvas
var current_index = 0

var colorLayers
var scoreRange

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.on_tape_start.connect(_on_tape_start)
	GameManager.on_tape_end.connect(_on_tape_end)
	GameManager.on_commit_tape.connect(_on_commit_tape)
	countdownTimer.on_timeout.connect(_on_timeout)
	
	var current_level_index = GameManager.current_level_index
	if current_level_index < 0:
		current_level_index = 0
		print('warning: current_level_index is -1')
	
	var totalTime	
	var refImage
	if current_level_index == 0:
		colorLayers = colorLayers1
		totalTime = totalTime1
		scoreRange = scoreRange1
		refImage = refImage1
	elif current_level_index == 1:
		colorLayers = colorLayers2
		totalTime = totalTime2
		scoreRange = scoreRange2
		refImage = refImage2
	elif current_level_index == 2:
		colorLayers = colorLayers3
		totalTime = totalTime3
		scoreRange = scoreRange3
		refImage = refImage2
	
	if len(scoreRange) != 4:
		print('incorrect length of scoreRange!')
	
	color_palette.setup(colorLayers)
	countdownTimer.start(totalTime)
	
	canvas = $Main/Canvas
	canvas.current_color_array = colorLayers
	
	current_index = 0
	
	ReferenceImage.texture = refImage	
	
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
	var rank = calculate_rank()
	end_scene.setup(rank)
	end_scene.visible = true
	AudioManager.stop_all()
	AudioManager.play_bgm(AudioManager.BGM.END)

func calculate_rank() -> String:
	# 依照你的規則：S(<=5), A(<=7), B(<=10), C(<=14), D(>14)
	if GameManager.total_tape_length <= scoreRange[0]:
		return "S"
	elif GameManager.total_tape_length <= scoreRange[1]:
		return "A"
	elif GameManager.total_tape_length <= scoreRange[2]:
		return "B"
	elif GameManager.total_tape_length <= scoreRange[3]:
		return "C"
	else:
		return "D"
