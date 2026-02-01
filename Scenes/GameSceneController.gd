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

@export var ComparsionVP : SubViewport
@export var ComparsionVPRoot : Node2D

var canvas : Canvas
var current_index = 0

var colorLayers
var scoreRange
var refImage
var ResultsRoot

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
		refImage = refImage3
	
	if len(scoreRange) != 4:
		print('incorrect length of scoreRange!')
	
	color_palette.setup(colorLayers)
	countdownTimer.start(totalTime)
	
	canvas = $Main/Canvas
	canvas.current_color_array = colorLayers
	
	current_index = 0
	
	ReferenceImage.texture = refImage
	
	ResultsRoot = $Main/Canvas/ResultsRoot
		
	ComparsionVP.size = Vector2i(1920, 1080) # don't know how to get exact area of middle combined part, get whole screen instead
	ComparsionVP.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	AudioManager.play_bgm(AudioManager.BGM.GAME, -10.0)

# cheats
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			_on_timeout()
		if event.keycode == KEY_BRACKETLEFT:
			stop_timer()
		if event.keycode == KEY_BRACKETRIGHT:
			resume_timer()
			
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
	# wait 0.1 second or we may miss copy last generated image!
	await get_tree().create_timer(0.1).timeout
	copy_sprites_to_subviewport(ResultsRoot, ComparsionVP, ComparsionVPRoot)
	await RenderingServer.frame_post_draw
	var combined = ComparsionVP.get_texture().get_image()
	var target = refImage.get_image()
	combined.save_png("user://combined.png")
	target.save_png("user://target.png")
	var diff = compare_images(combined, target)
	end_scene.setup(rank, diff)
	end_scene.visible = true
	AudioManager.stop_all()
	AudioManager.play_bgm(AudioManager.BGM.END, -10.0)

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

func color_distance(a: Color, b: Color) -> float:
	var dr = a.r - b.r
	var dg = a.g - b.g
	var db = a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)

func copy_sprites_to_subviewport(
	source_root: Node,
	subviewport: SubViewport,
	target_root: Node2D
) -> void:
	for child in source_root.get_children():
		if child is Sprite2D:
			var clone: Sprite2D = child.duplicate()
			target_root.add_child(clone)

			# 保留世界座標
			clone.global_position = child.global_position
			clone.global_rotation = child.global_rotation
			clone.global_scale = child.global_scale

		# 繼續往下找
		copy_sprites_to_subviewport(child, subviewport, target_root)

func compare_images(a: Image, b: Image, threshold := 0.01) -> float:
	# assert(a.get_size() == b.get_size())

	a.convert(Image.FORMAT_RGBA8)
	b.convert(Image.FORMAT_RGBA8)

	var diff := 0
	var total := b.get_width() * b.get_height()

	for y in b.get_height():
		for x in b.get_width():
			var bPixel = b.get_pixel(x, y)
			if color_distance(bPixel, Color(1, 1, 1, 1)) < threshold:
				# skip white pixels
				continue
			var aPixel = a.get_pixel(1920 / 2 - 256 + x, 1080 / 2 - 256 + y)
			if bPixel.a > threshold:
				if color_distance(aPixel, bPixel) > threshold:
					diff += 1
	print('raw diff = ', diff)
	return 1.0 - float(diff) / total

func stop_timer():
	countdownTimer.pause()
	
func resume_timer():
	countdownTimer.resume()
