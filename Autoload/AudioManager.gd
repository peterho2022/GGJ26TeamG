extends Node

enum SFX {
	TAPE_RIP,
	TAPE_PASTE
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
	SFX.TAPE_PASTE: [
		preload("res://Assets/Audio/sfx/tape_paste_sfx.mp3"),
	]
}

@export var bgm_map := {
	BGM.MENU: preload("res://Assets/Audio/bgm/jazz-background-music-416542.mp3"),
}

@export var max_players := 8

var _players: Array[AudioStreamPlayer] = []

func _ready():
	for i in max_players:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX" # 記得在 Audio Bus 裡建 SFX
		add_child(p)
		_players.append(p)

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
	for p in _players:
		if not p.playing:
			return p
	return null

func play_bgm(bgm: BGM, volume_db := 0.0, pitch := 1.0):
	if not bgm_map.has(bgm):
		push_warning("BGM not found: %s" % bgm)
		return

	var player := _get_free_player()
	if player == null:
		return

	player.stream = bgm_map[bgm]
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()

func stop_all():
	for p in _players:
		if p.playing:
			p.stop()
