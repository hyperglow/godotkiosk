extends SubViewport

@onready var anim_player : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	KioskManager.GameStarted.connect(_game_started)
	KioskManager.GameExited.connect(_game_exited)

func _game_started():
	anim_player.play("game_start")
	await anim_player.animation_finished
	render_target_update_mode = SubViewport.UPDATE_DISABLED

func _game_exited():
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	anim_player.play("game_exit")

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_APPLICATION_FOCUS_OUT:
			render_target_update_mode = SubViewport.UPDATE_DISABLED
		Node.NOTIFICATION_APPLICATION_FOCUS_IN:
			render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE