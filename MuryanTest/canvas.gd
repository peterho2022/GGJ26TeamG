extends Node2D

@export var canvas_size: Vector2i = Vector2i(1024, 1024)
@export var tape_width_px: float = 24.0

@export var mask_vp_path: NodePath
@export var mask_root_path: NodePath
@export var results_root_path: NodePath
@export var tape_overlay_path: NodePath

@export var tape_overlay_shader: Shader
@export var paint_layer_shader: Shader

var _mask_vp: SubViewport
var _mask_root: Node2D
var _results_root: Node2D
var _tape_overlay: Sprite2D

var _white_tex: ImageTexture
var _dragging := false
var _start_local := Vector2.ZERO

var current_color := Color(0.9, 0.2, 0.2, 1.0)

func _ready() -> void:
	_mask_vp = get_node(mask_vp_path) as SubViewport
	_mask_root = get_node(mask_root_path) as Node2D
	_results_root = get_node(results_root_path) as Node2D
	_tape_overlay = get_node(tape_overlay_path) as Sprite2D

	# 1x1 白貼圖，用 scale 拉到 canvas_size（用於 overlay / layer 顯示）
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_white_tex = ImageTexture.create_from_image(img)

	_setup_mask_viewport()
	_setup_tape_overlay()

func _setup_mask_viewport() -> void:
	_mask_vp.size = canvas_size
	_mask_vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_mask_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _setup_tape_overlay() -> void:
	_tape_overlay.texture = _white_tex
	_tape_overlay.centered = false
	_tape_overlay.position = Vector2.ZERO
	_tape_overlay.scale = Vector2(canvas_size)
	_tape_overlay.z_index = 1000  # 確保在最上層（或用場景順序）

	var mat := ShaderMaterial.new()
	mat.shader = tape_overlay_shader
	mat.set_shader_parameter("mask_tex", _mask_vp.get_texture())
	_tape_overlay.material = mat

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_start_local = get_local_mouse_position()
		else:
			if _dragging:
				_dragging = false
				var end_local := get_local_mouse_position()
				_add_tape_segment(_start_local, end_local)

	if event.is_action_pressed("undo_tape"):
		_undo_last_tape()

	if event.is_action_pressed("commit_color"):
		await _commit_layer()

func _add_tape_segment(a: Vector2, b: Vector2) -> void:
	if a.distance_to(b) < 2.0:
		return

	var poly := _make_tape_poly(a, b, tape_width_px * 0.5)
	if poly.is_empty():
		return

	var p := Polygon2D.new()
	p.polygon = poly
	p.color = Color.WHITE  # 白=膠帶遮罩
	_mask_root.add_child(p)

func _make_tape_poly(a: Vector2, b: Vector2, half_w: float) -> PackedVector2Array:
	var dir := b - a
	if dir.length() < 0.001:
		return PackedVector2Array()
	dir = dir.normalized()
	var n := Vector2(-dir.y, dir.x) * half_w
	return PackedVector2Array([a + n, b + n, b - n, a - n])

func _undo_last_tape() -> void:
	var c := _mask_root.get_child_count()
	if c > 0:
		_mask_root.get_child(c - 1).queue_free()

func _clear_mask() -> void:
	for child in _mask_root.get_children():
		(child as Node).queue_free()

func _commit_layer() -> void:
	# 依官方建議：抓 viewport 圖像要等該幀渲染結束，不然可能拿到空貼圖。 :contentReference[oaicite:5]{index=5}
	await RenderingServer.frame_post_draw

	# 凍結本回合遮罩：把 ViewportTexture 轉成 ImageTexture（很慢，別每幀做，只在 commit 做）。 :contentReference[oaicite:6]{index=6}
	var img := _mask_vp.get_texture().get_image()
	var saved_mask := ImageTexture.create_from_image(img)

	# 新增一層「顏色結果」
	var layer := Sprite2D.new()
	layer.texture = _white_tex
	layer.centered = false
	layer.position = Vector2.ZERO
	layer.scale = Vector2(canvas_size)

	var mat := ShaderMaterial.new()
	mat.shader = paint_layer_shader
	mat.set_shader_parameter("mask_tex", saved_mask)
	mat.set_shader_parameter("layer_color", current_color)
	layer.material = mat

	_results_root.add_child(layer)

	# 撕掉膠帶：清空 mask，TapeOverlay 會立刻變空（因為它讀的是 MaskVP 畫面）
	_clear_mask()
