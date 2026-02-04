extends HBoxContainer

var dot_filled = preload("res://assets/interface/checkbox_checked.png")
var dot_outline = preload("res://assets/interface/checkbox_unchecked.png")
var dot_scene : PackedScene = preload("res://scenes/dot_select.tscn")

var _dots : Array[TextureRect]

func _ready() -> void:
	KioskManager.GameIndexChanged.connect(_set_selected_game)

	_create_game_dots()
	_set_selected_game()

func _create_game_dots():
	for child in get_children():
		if child is TextureRect:
			child.queue_free()
	for i in range(KioskManager.games.size()):
		var dot = dot_scene.instantiate()
		add_child(dot)
		_dots.push_back(dot)

func _set_selected_game(_index: int = 0, _added: bool = true):
	for i in range(_dots.size()):
		var dot = _dots[i]
		if i == KioskManager.current_game_index:
			dot.texture = dot_filled
		else:
			dot.texture = dot_outline