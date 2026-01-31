extends Node2D

var color_palette : ColorPaletteController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_palette = $ColorPalette
	color_palette.setup([
		Color(1, 0, 0, 1),
		Color(1, 1, 0, 1),
		Color(1, 0, 1, 1),
		Color(0, 1, 0, 1),
		Color(0, 1, 1, 1),
		Color(0, 0, 1, 1),
		Color(1, 1, 1, 1),
	])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		color_palette.next_color()
