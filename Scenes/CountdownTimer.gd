extends Control

class_name CountdownTimer

signal on_timeout

@export var prefix: String
@export var duration_sec: float = 10.0   # 到期時間（秒）
@export var target_label: Label

var _end_time: float = 0.0
var _running := false

func _ready():
	pass

func start(seconds: float):
	_end_time = Time.get_ticks_msec() / 1000.0 + seconds
	_running = true

func _process(_delta):
	if not _running:
		return

	var remaining := _end_time - Time.get_ticks_msec() / 1000.0
	if remaining <= 0.0:
		on_timeout.emit()
		remaining = 0.0
		_running = false

	target_label.text = prefix + str(int(ceil(remaining)))
