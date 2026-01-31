extends Node2D

signal start_tape(mouse_global_position: Vector2)
signal change_tape_length(length: float)
signal end_tape

@export var paper_color: Color = Color(0.95, 0.94, 0.90, 1.0) # 紙色
@export var tape_color: Color = Color(1.0, 0.92, 0.55, 1.0)   # 膠帶色
@export var paper_bg_path: NodePath

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
var _paper_bg: Sprite2D

var _white_tex: ImageTexture
var _dragging := false
var _start_local := Vector2.ZERO

# 預覽膠帶需要的功能
enum PlaceState { IDLE, LENGTH_TIMING }
var _state: PlaceState = PlaceState.IDLE

@export var min_len_px: float = 40.0
@export var max_len_px: float = 260.0
@export var length_cycles_per_sec: float = 1.2   # 每秒來回幾次（節奏）

var _anchor_local := Vector2.ZERO
var _t := 0.0

var _preview_poly: Polygon2D = null

var current_color_index := 0
@export var current_color_array: Array[Color]

var current_end_local: Vector2

func _ready() -> void:
	_mask_vp = get_node(mask_vp_path) as SubViewport
	_mask_root = get_node(mask_root_path) as Node2D
	_results_root = get_node(results_root_path) as Node2D
	_tape_overlay = get_node(tape_overlay_path) as Sprite2D
	_paper_bg = get_node(paper_bg_path) as Sprite2D

	# 1x1 白貼圖，用 scale 拉到 canvas_size（用於 overlay / layer 顯示）
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_white_tex = ImageTexture.create_from_image(img)
	_center_canvas_on_screen()
	_setup_mask_viewport()
	_setup_tape_overlay()
	_setup_paper_background()

# 假設 Canvas 節點的原點是畫布左上角（你目前 centered=false 就是這種）
func _center_canvas_on_screen():
	var view_size := get_viewport_rect().size
	position = (view_size - Vector2(canvas_size)) * 0.5

func _setup_paper_background() -> void:
	_paper_bg.texture = _white_tex
	_paper_bg.centered = false
	_paper_bg.position = Vector2.ZERO
	_paper_bg.scale = Vector2(canvas_size)
	_paper_bg.modulate = paper_color
	_paper_bg.z_index = -1000  # 確保在最底下（或用節點順序）

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
	mat.set_shader_parameter("tape_color", tape_color)
	_tape_overlay.material = mat

func _process(delta: float) -> void:
	if _state != PlaceState.LENGTH_TIMING:
		return

	_t += delta

	# 角度跟著滑鼠（方向由 A 指向滑鼠）
	var mouse_local := get_local_mouse_position()
	var dir := mouse_local - _anchor_local
	if dir.length() < 0.001:
		dir = Vector2.RIGHT
	else:
		dir = dir.normalized()

	# 長度在 min~max 間來回變動（sin 波）
	var s := 0.5 + 0.5 * sin(_t * TAU * length_cycles_per_sec)  # 0..1
	var length := lerpf(min_len_px, max_len_px, s)
	change_tape_length.emit(length)

	var end_local := _anchor_local + dir * length
	#current_end_local = _update_preview_polygon(_anchor_local, end_local)
	_update_preview_polygon(_anchor_local, end_local)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _state == PlaceState.IDLE:
			start_tape.emit(get_global_mouse_position())
			_begin_length_timing()
		elif _state == PlaceState.LENGTH_TIMING:
			_finalize_current_tape()
			end_tape.emit()

	# 取消（可選）：右鍵或 ESC 取消這次預覽
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) \
		or event.is_action_pressed("ui_cancel"):
		_cancel_preview()

	# Undo：如果正在預覽，Undo = 取消預覽；如果空閒，Undo = 移除上一段永久膠帶
	if event.is_action_pressed("undo_tape"):
		if _state == PlaceState.LENGTH_TIMING:
			_cancel_preview()
		else:
			_undo_last_tape()

	# 上色確認：建議只允許在 IDLE（避免你還在跑長度時就 commit）
	if event.is_action_pressed("commit_color"):
		if current_color_index >= current_color_array.size():
		#Game End
			return
		if _state == PlaceState.IDLE:
			await _commit_layer()


func _add_tape_segment(a: Vector2, b: Vector2) -> void:
	if a.distance_to(b) < 2.0:
		return

	var poly := _make_tape_poly(a, b, tape_width_px * 0.5)
	if poly.is_empty():
		return

	var p := Polygon2D.new()
	p.polygon = poly
	p.color = tape_color  # 白=膠帶遮罩
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
	mat.set_shader_parameter("layer_color", current_color_array[current_color_index])
	current_color_index += 1
	layer.material = mat

	_results_root.add_child(layer)

	# 撕掉膠帶：清空 mask，TapeOverlay 會立刻變空（因為它讀的是 MaskVP 畫面）
	_clear_mask()

func _begin_length_timing() -> void:
	_state = PlaceState.LENGTH_TIMING
	_t = 0.0
	_anchor_local = get_local_mouse_position()

	if _preview_poly == null:
		_preview_poly = Polygon2D.new()
		_preview_poly.color = Color.WHITE  # 白=膠帶遮罩
		_mask_root.add_child(_preview_poly)

func _update_preview_polygon(a: Vector2, b: Vector2) -> void:
	var poly := _make_tape_poly(a, b, tape_width_px * 0.5)
	_preview_poly.polygon = poly
	#return b

func _finalize_current_tape() -> void:
	# 讓目前的 preview 變成永久膠帶：方法是「把 preview 變成普通節點」然後清掉引用
	_state = PlaceState.IDLE
	_preview_poly = null  # 不再更新它，視為永久膠帶

func _cancel_preview() -> void:
	if _state != PlaceState.LENGTH_TIMING:
		return
	_state = PlaceState.IDLE
	if _preview_poly != null:
		_preview_poly.queue_free()
		_preview_poly = null
