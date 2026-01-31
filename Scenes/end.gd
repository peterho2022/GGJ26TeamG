extends Node

class_name EndScene

@onready var score_label = $Background/VBoxContainer2/ScoreLabel
@onready var rank_label = $Background/VBoxContainer2/RankLabel	

func setup():
	
	# 1. 顯示數字
	var final_score = GameManager.total_tape_length
	score_label.text =  "最終膠帶使用量: %.2f m" % (final_score / 100.0)
	
	# 2. 顯示評價
	var final_rank = GameManager.calculate_rank()
	rank_label.text = "獲得評價: " + final_rank
	
	# (選用) 根據評價變色
	if final_rank == "S":
		rank_label.modulate = Color.GOLD
	elif final_rank == "D":
		rank_label.modulate = Color.GRAY

# --- 按鈕功能 ---
func _on_button_pressed():
	GameManager.back_to_menu()
