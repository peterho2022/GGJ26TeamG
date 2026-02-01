extends Control

# 假設你把新增的節點命名為 Detector
@onready var detector = $Detector

var pos_hidden: Vector2
var pos_shown: Vector2

func _ready():
	pos_shown = position
	# 這裡可以根據你的需求調整隱藏位置
	pos_hidden = Vector2(-size.x - 300, pos_shown.y) 
	position = pos_hidden

	# 關鍵：改為連結 Detector 的訊號，而不是 self 的訊號
	detector.mouse_entered.connect(_on_mouse_entered)
	detector.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "position", pos_shown, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "position", pos_hidden, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
