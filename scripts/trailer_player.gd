class_name TrailerPlayer extends VideoStreamPlayer

func _ready() -> void:
    KioskManager.GameIndexChanged.connect(func(_a: int, _b: bool): _play_game_trailer())
    KioskManager.GameStarted.connect(func(): paused = true)
    KioskManager.GameExited.connect(func(): paused = false)
    volume = 0.0
    _play_game_trailer()

func _play_game_trailer():
    stop()
    var trailer := KioskManager.games[KioskManager.current_game_index].trailer
    stream = trailer
    play()

func _notification(what: int) -> void:
    match what:
        Node.NOTIFICATION_APPLICATION_FOCUS_OUT:
            paused = true
        Node.NOTIFICATION_APPLICATION_FOCUS_IN:
            if paused:
                paused = false