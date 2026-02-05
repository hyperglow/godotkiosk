class_name TopContainer extends PanelContainer

func _ready() -> void:
	KioskManager.TrailerStart.connect(_hide)
	KioskManager.TrailerExit.connect(_show)
	KioskManager.GameStarted.connect(_hide)
	KioskManager.GameExited.connect(_show)

func _show():
	visible = true

func _hide():
	visible = false