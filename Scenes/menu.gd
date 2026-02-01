extends Node


@onready var btn_level_1: Button = $Background/VBoxContainer/Btn_Level1
@onready var btn_level_2: Button = $Background/VBoxContainer/Btn_Level2
@onready var btn_level_3: Button = $Background/VBoxContainer/Btn_Level3
@onready var btn_exit: Button = $Background/VBoxContainer/Btn_Exit


func _ready():
	AudioManager.play_bgm(AudioManager.BGM.MENU, -10.0)
	

func _on_btn_level_1_pressed():
	print("按鈕：前往第一關")
	GameManager.load_specific_level(0)


func _on_btn_level_2_pressed():
	print("按鈕：前往第二關")
	GameManager.load_specific_level(1)

func _on_btn_level_3_pressed():
	print("按鈕：前往第三關")
	GameManager.load_specific_level(2)


func _on_btn_exit_pressed() -> void:
	print("按鈕：離開遊戲")
	get_tree().quit()


func _on_btn_level_1_mouse_entered() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_1.add_theme_font_size_override("font_size", int(round(v))),100.0, 150.0, 0.2
	)
	

func _on_btn_level_1_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_1.add_theme_font_size_override("font_size", int(round(v))),150.0, 100.0, 0.3
	)
	


func _on_btn_level_2_mouse_entered() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_2.add_theme_font_size_override("font_size", int(round(v))),100.0, 150.0, 0.2
	)


func _on_btn_level_2_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_2.add_theme_font_size_override("font_size", int(round(v))),150.0, 100.0, 0.3
	)


func _on_btn_level_3_mouse_entered() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_3.add_theme_font_size_override("font_size", int(round(v))),100.0, 150.0, 0.2
	)


func _on_btn_level_3_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(v: float) -> void:
		btn_level_3.add_theme_font_size_override("font_size", int(round(v))),150.0, 100.0, 0.3
	)


func _on_btn_exit_mouse_entered() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(v: float) -> void:
		btn_exit.add_theme_font_size_override("font_size", int(round(v))),100.0, 130.0, 0.2
	)


func _on_btn_exit_mouse_exited() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(v: float) -> void:
		btn_exit.add_theme_font_size_override("font_size", int(round(v))),130.0, 100.0, 0.3
	)
