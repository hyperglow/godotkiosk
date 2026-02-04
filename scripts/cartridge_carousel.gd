class_name CartridgeCarousel extends Node3D

@export var current_game_index := 0:
	get:
		return KioskManager.current_game_index
	set(value):
		KioskManager.current_game_index = value
@export var cartridge_distance := 0.8

var _cartridge_scene : PackedScene = preload("res://scenes/cartridge.tscn")
var _cartridge : Array[PathFollow3D] = []

@onready var path : Path3D = $Path3D
var curve : Curve3D :
	get:
		return path.curve

func _ready() -> void:
	if KioskManager.carousel:
		queue_free()
	KioskManager.carousel = self
	KioskManager.GameIndexChanged.connect(_move_points)
	_create_carousel()
	_distrubute_points()

func _create_carousel():
	for game in KioskManager.games:
		var cart = _cartridge_scene.instantiate()
		var cover := game.cover
		var mesh := cart.get_child(0) as MeshInstance3D
		if mesh:
			mesh.mesh.surface_get_material(1).albedo_texture = cover
		path.add_child(cart)
		_cartridge.push_back(cart)


# game 0, game 1, game 2, game 3
# current index => spline_length / 2
# index - current_index -> current_index = 2 -> game 0: -2, game 1: -1, game 2: 0, game 3: 1

func _get_offset_position(index := 0) -> float:
	# var spacing := curve.get_baked_length() / KioskManager.games.size()
	# var pos := curve.sample_baked(spacing * (index % _cartridge.size()), true)
	# return pos * path.scale + path.position
	# var spacing := 1.0 / KioskManager.games.size()
	# return (index + current_game_index) * spacing
	var half_length := curve.get_baked_length() / 2
	var pos = (index - current_game_index) * cartridge_distance + half_length
	return pos

func _distrubute_points():
	for i in range(_cartridge.size()):
		var cart := _cartridge[i]
		cart.progress = _get_offset_position(i)

func _move_points(_index := 0, added := true):
	print("Moving points")
	#_distrubute_points()
	for i in range(_cartridge.size()):
		var move_tween : Tween = create_tween()
		var cart := _cartridge[i]
		var cart_mesh := cart.get_child(0) as MeshInstance3D
		var target_progress = _get_offset_position(i)
		move_tween.tween_property(cart, "progress", target_progress, 0.4)
		move_tween.set_trans(Tween.TRANS_SINE)
		move_tween.parallel().tween_property(cart_mesh, "rotation_degrees", Vector3(0,-90, -10 if added else 10), 0.1)
		#move_tween.tween_interval(0.4)
		move_tween.tween_property(cart_mesh, "rotation_degrees", Vector3(0,-90, 0), 0.1)
		
