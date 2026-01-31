extends Node

@onready var white_vp := $ClipTest/WhiteSubViewport
@onready var white_sprite := $ClipTest/WhiteFullScreenRect

@onready var blue_vp := $ClipTest/BlueSubViewport
@onready var blue_sprite := $ClipTest/BlueFullScreenRect

@onready var brown_vp := $ClipTest/BrownSubViewport
@onready var brown_sprite := $ClipTest/BrownFullScreenRect

@onready var red_vp := $ClipTest/RedSubViewport
@onready var red_sprite := $ClipTest/RedFullScreenRect

@onready var skin_vp := $ClipTest/SkinSubViewport
@onready var skin_sprite := $ClipTest/SkinFullScreenRect

@onready var button_vp := $ClipTest/ButtonSubViewport
@onready var button_sprite := $ClipTest/ButtonFullScreenRect

@onready var blue_mask := $ClipTest/BlueSubViewport/Mask
@onready var brown_mask := $ClipTest/BrownSubViewport/Mask
@onready var red_mask := $ClipTest/RedSubViewport/Mask
@onready var skin_mask := $ClipTest/SkinSubViewport/Mask
@onready var button_mask := $ClipTest/ButtonSubViewport/Mask

@onready var target_mask

func _ready():
	var shader = preload("res://YanagiTest/Utils/clip_test_mask.gdshader")
	var mat
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	white_sprite.material = mat
	white_sprite.material.set_shader_parameter(
		"mask_tex",
		white_vp.get_texture()
	)
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	blue_sprite.material = mat
	blue_sprite.material.set_shader_parameter(
		"mask_tex",
		blue_vp.get_texture()
	)	
	blue_sprite.material.set_shader_parameter(
		"albedo",
		Vector4(0, 0, 1, 1)
	)
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	brown_sprite.material = mat
	brown_sprite.material.set_shader_parameter(
		"mask_tex",
		brown_vp.get_texture()
	)	
	brown_sprite.material.set_shader_parameter(
		"albedo",
		Vector4(137,81,41, 255) / 255.0
	)
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	red_sprite.material = mat
	red_sprite.material.set_shader_parameter(
		"mask_tex",
		red_vp.get_texture()
	)	
	red_sprite.material.set_shader_parameter(
		"albedo",
		Vector4(1, 0, 0, 1)
	)
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	skin_sprite.material = mat
	skin_sprite.material.set_shader_parameter(
		"mask_tex",
		skin_vp.get_texture()
	)	
	skin_sprite.material.set_shader_parameter(
		"albedo",
		Vector4(255, 207, 143, 255) / 255
	)
	
	mat = ShaderMaterial.new()
	mat.shader = shader
	button_sprite.material = mat
	button_sprite.material.set_shader_parameter(
		"mask_tex",
		button_vp.get_texture()
	)	
	button_sprite.material.set_shader_parameter(
		"albedo",
		Vector4(255, 227, 99, 255) / 255
	)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				target_mask = blue_mask
			KEY_2:
				target_mask = brown_mask
			KEY_3:
				target_mask = red_mask
			KEY_4:
				target_mask = skin_mask
			KEY_5:
				target_mask = button_mask
	elif event is InputEventMouseMotion:
		if target_mask:
			var pos = get_viewport().get_mouse_position()
			target_mask.position = pos
