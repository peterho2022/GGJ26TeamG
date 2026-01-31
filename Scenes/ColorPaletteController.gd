extends Control

class_name ColorPaletteController

@export var rotate_angle : float = -30.0
@export var rotate_speed : float = 3

@export var scale_up : float = 1.0
@export var scale_down : float = 0.5
@export var scale_speed : float = 3

var next_id : int = 0
var max_next_id : int = 0

var colors : Array[Sprite2D]
var desire_rotate_angle = 0.0

var palette : Node2D
var brush : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	palette = $Palette
	desire_rotate_angle = palette.rotation
	brush = $Brush/Brush
	colors = [
		$Palette/Color1,
		$Palette/Color2,
		$Palette/Color3,
		$Palette/Color4,
		$Palette/Color5,
		$Palette/Color6,
		$Palette/Color7,
		$Palette/Color8,
		$Palette/Color9,
		$Palette/Color10,
		$Palette/Color11,
		$Palette/Color12
	]
	for s in colors:
		s.visible = false

func setup(inColors: Array[Color]):
	if len(inColors) > len(colors):
		print("inColor size too long: ", len(inColors))
	max_next_id = len(inColors)
	for i in range(len(inColors)):
		colors[i].visible = true
		colors[i].modulate = inColors[i]
		var res = scale_up if i == next_id else scale_down
		colors[i].scale = Vector2.ONE * res

func _process(delta):	
	palette.rotation = lerp_angle(palette.rotation, desire_rotate_angle, rotate_speed * delta)
	for i in range(len(colors)):
		if colors[i].visible:
			var res = lerp(colors[i].scale.x, scale_up if i == next_id else scale_down, scale_speed * delta )
			colors[i].scale = Vector2.ONE * res
	
func next_color():
	if next_id >= (max_next_id - 1):
		print('reach end')
		return
	desire_rotate_angle += deg_to_rad(rotate_angle)
	next_id = (next_id + 1 + len(colors)) % len(colors)
	brush.modulate = colors[next_id].modulate
	print('next desire_rotate_angle = ', desire_rotate_angle)
	print('next_id = ', next_id)
	print('max_next_id = ', max_next_id)
