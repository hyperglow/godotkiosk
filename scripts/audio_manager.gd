class_name AudioManager	 extends AudioStreamPlayer

@onready var bg_music : AudioStreamPlayer = $BgMusic
@export var sound_files : Dictionary[Sounds, AudioStream] = {}

enum Sounds {
	BOOT,
	SWITCH,
	START
}

func _ready() -> void:
	if KioskManager.audio_manager:
		if KioskManager.audio_manager != self:
			queue_free()
			return
	KioskManager.audio_manager = self
	play()
	play_sound(Sounds.BOOT)	
	await get_tree().create_timer(2).timeout
	bg_music.play(0.0)
	KioskManager.GameStarted.connect(func(): bg_music.stop())
	KioskManager.GameExited.connect(func(): bg_music.play())
	KioskManager.TrailerStart.connect(func(): bg_music.stop())
	KioskManager.TrailerExit.connect(func(): bg_music.play())

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_APPLICATION_FOCUS_OUT:
			bg_music.stop()
		Node.NOTIFICATION_APPLICATION_FOCUS_IN:
			bg_music.play()

func play_sound(sound: Sounds):
	if not sound_files.keys().has(sound):
		return
	
	var playback := get_stream_playback() as AudioStreamPlaybackPolyphonic
	playback.play_stream(sound_files[sound])