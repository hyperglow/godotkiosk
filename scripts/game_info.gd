extends Control

@onready var title_label : Label = $GameInfo/VBoxContainer/GameTitle
@onready var year_label : Label = $GameInfo/VBoxContainer/GameYear
@onready var authors_label : Label = $GameInfo/VBoxContainer2/GameAuthors
@onready var tagline_label : Label = $GameInfo/VBoxContainer2/GameTagline

@onready var game_info : Control = $GameInfo
@onready var trailer_hint : Control = $TrailerHint

var _tweens : Dictionary[Label, Tween] = {}

func _ready() -> void:
	KioskManager.GameIndexChanged.connect(func(_a: int, _b: bool): _display_game_info())
	KioskManager.TrailerStart.connect(func(): _switch_type(true))
	KioskManager.TrailerExit.connect(func(): _switch_type(false))
	_display_game_info()
	_switch_type(false)

func _display_game_info():
	var data := KioskManager.games[KioskManager.current_game_index]
	# title_label.text = data.name
	# year_label.text = data.year
	# authors_label.text = data.authors
	# tagline_label.text = data.tagline
	typewriter_animation(title_label, data.name)
	typewriter_animation(year_label, data.year)
	typewriter_animation(authors_label, data.authors)
	typewriter_animation(tagline_label, data.tagline)

func typewriter_animation(label: Label, text: String):
	if _tweens.keys().has(label):
		var pretween := _tweens[label]
		if pretween.is_valid():
			pretween.kill()

	var callable := Callable(self, "_write")
	
	label.text = ""
	var tween = create_tween()
	var letters := text.split()
	tween.set_loops(letters.size())
	tween.tween_callback(callable.bind(label, letters)).set_delay(0.03)
	
	_tweens[label] = tween

func _write(label: Label, letters: Array[String]):
	var current_count = label.text.length()
	label.text = label.text + letters[current_count]

func _switch_type(trailer := false):
	game_info.visible = not trailer
	trailer_hint.visible = trailer