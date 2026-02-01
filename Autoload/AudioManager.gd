extends Node

enum SFX {
	TAPE_RIP,
	TAPE_PASTE,
	PAINT
}

enum BGM {
	MENU,
	GAME,
	END
}

@export var sfx_map := {
	SFX.TAPE_RIP: [
		preload("res://Assets/Audio/sfx/tape_sfx_1.mp3"),
		preload("res://Assets/Audio/sfx/tape_sfx_2.mp3"),
		preload("res://Assets/Audio/sfx/tape_sfx_3.mp3"),
		preload("res://Assets/Audio/sfx/tape_sfx_4.mp3"),
		preload("res://Assets/Audio/sfx/tape_sfx_5.mp3"),
		preload("res://Assets/Audio/sfx/tape_sfx_6.mp3"),
	],
	SFX.TAPE_PASTE: [ preload("res://Assets/Audio/sfx/tape_paste_sfx.mp3") ],
	SFX.PAINT: [ preload("res://Assets/Audio/sfx/paint_sfx.mp3") ]
}

@export var bgm_map := {
	BGM.GAME: preload("res://Assets/Audio/bgm/playing.mp3"),
	BGM.MENU: preload("res://Assets/Audio/bgm/menu.mp3"),
	BGM.END: preload("res://Assets/Audio/bgm/win.mp3")
}

@export var max_players := 8

# SFX 用的一池播放器
var _sfx_players: Array[AudioStreamPlayer] = []
# BGM 用的專屬播放器 (新增這個!)
var _bgm_player: AudioStreamPlayer

func _ready():
	for i in max_players:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX" 
		add_child(p)
		_sfx_players.append(p)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master" 
	add_child(_bgm_player)


func play_sfx(sfx: SFX, volume_db := 0.0, pitch := 1.0):
	if not sfx_map.has(sfx):
		push_warning("SFX not found: %s" % sfx)
		return

	var player := _get_free_player()
	if player == null:
		return

	player.stream = sfx_map[sfx].pick_random()
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	return null


func play_bgm(bgm: BGM, volume_db := 0.0, pitch := 1.0):
	if not bgm_map.has(bgm):
		push_warning("BGM not found: %s" % bgm)
		return
	
	var stream = bgm_map[bgm]
	
	# 邏輯判斷：如果現在已經在播這首歌，就只要調整音量，不要重播
	if _bgm_player.stream == stream and _bgm_player.playing:
		_bgm_player.volume_db = volume_db # 更新音量
		return

	# 如果是不同的歌，就切換
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = volume_db
	_bgm_player.pitch_scale = pitch
	_bgm_player.play()

func stop_all():
	# 停止所有 SFX
	for p in _sfx_players:
		if p.playing:
			p.stop()
	# 停止 BGM
	if _bgm_player.playing:
		_bgm_player.stop()
