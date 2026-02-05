class_name TrailerPlayer extends Control

@onready var video : VideoStreamPlayer = $VideoContainer/PanelContainer/GameVideo
@onready var game_cart_hint : Control = $GameCartHint
var current_trailer := 0

func _ready() -> void:
	KioskManager.GameIndexChanged.connect(func(_a: int, _b: bool): _play_game_trailer())
	KioskManager.GameStarted.connect(_game_start)
	KioskManager.GameExited.connect(_game_exit)
	KioskManager.TrailerStart.connect(_start_trailer)
	KioskManager.TrailerExit.connect(_exit_trailer)
	video.volume = 0.0
	_play_game_trailer()

func _play_game_trailer():
	video.stop()
	current_trailer = KioskManager.current_game_index
	var trailer := KioskManager.games[KioskManager.current_game_index].trailer
	video.stream = trailer
	video.play()

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_APPLICATION_FOCUS_OUT:
			video.paused = true
		Node.NOTIFICATION_APPLICATION_FOCUS_IN:
			if video.paused:
				video.paused = false

func _start_trailer():
	video.stop()
	game_cart_hint.visible = false
	video.volume = 1.1
	video.loop = false
	video.play()

func _exit_trailer():
	game_cart_hint.visible = true
	video.volume = 0.0
	video.loop = true
	_play_game_trailer()

func _on_game_video_finished() -> void:
	if not KioskManager.in_trailer:
		return
	
	current_trailer += 1
	if current_trailer >= KioskManager.games.size():
		current_trailer = 0
	var trailer := KioskManager.games[current_trailer].trailer
	video.stream = trailer
	video.play()

func _game_start():
	video.paused = false
	visible = false

func _game_exit():
	video.paused = true
	visible = true