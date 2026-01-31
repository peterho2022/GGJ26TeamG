extends Node

@onready var vp := $ClipTest/SubViewport
@onready var sprite := $ClipTest/Target

func _ready():
	sprite.material.set_shader_parameter(
		"mask_tex",
		vp.get_texture()
	)
