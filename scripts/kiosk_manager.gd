extends Node

signal GameIndexChanged(new_index: int, added : bool)
signal GameStarted()
signal GameExited()
signal TrailerStart()
signal TrailerExit()

const debug_data := false
const trailer_delay := 30.0
var games : Array[GameData] = []
var carousel : CartridgeCarousel
var current_game_index := 0:
	set(value):
		current_game_index = (value if value >= 0 else games.size() - 1)  % games.size()
var current_game : GameData:
	get:
		return games[current_game_index]
var game_running:
	get:
		if current_game_pid == -1:
			return false
		return OS.is_process_running(current_game_pid)
var games_directory: String
var current_game_pid: int = -1
var audio_manager : AudioManager
var audio_manager_scene : PackedScene = preload("res://scenes/AudioManager.tscn")
var in_trailer : bool = false:
	set(value):
		if value != in_trailer:
			in_trailer = value
			if value:
				TrailerStart.emit()
			else:
				TrailerExit.emit()
var time_since_input := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if OS.has_feature("editor"):
		games_directory = ProjectSettings.globalize_path("res://games/")
	else:
		games_directory = OS.get_executable_path().get_base_dir().path_join("games/")

	audio_manager = audio_manager_scene.instantiate()
	add_child(audio_manager)

	if debug_data:
		_populate_test_data()
	else:
		_scan_directory()

# TODO: create game loading function
func _scan_directory():
	var dir := DirAccess.open(games_directory)
	var game_dirs := dir.get_directories()
	for game_dir in game_dirs:
		var full_path = games_directory.path_join(game_dir)
		_scan_game(full_path)
	# if dir:
	# 	dir.list_dir_begin()
	# 	var item_name := dir.get_next()
	# 	while item_name != "":
	# 		var full_path := games_directory.path_join(item_name)
	# 		if dir.current_is_dir() and item_name != "." and item_name != "..":
	# 			_scan_game(full_path, item_name)
				
func _scan_game(path : String):
	var dir := DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var game_data := GameData.new()
	var files := dir.get_files()
	for file in files:
		if file.ends_with(".exe"):
			game_data.exe_path = path.path_join(file)
		if file.begins_with("icon") and (file.ends_with(".png") or file.ends_with(".jpg") or file.ends_with("webp")):
			var image = Image.load_from_file(path.path_join(file))
			game_data.cover = ImageTexture.create_from_image(image)
		if file.begins_with("trailer") and file.ends_with(".ogv"):
			var trailer = VideoStreamTheora.new()
			trailer.file = path.path_join(file)
			game_data.trailer = trailer
		if file.begins_with("info") and file.ends_with(".json"):
			var info_file = FileAccess.open(path.path_join(file), FileAccess.READ)
			var info_json_string = info_file.get_as_text()
			var info_json = JSON.parse_string(info_json_string)
			if info_json:
				game_data.authors = info_json["author"]
				game_data.name = info_json["name"]
				game_data.year = info_json["year"]
				game_data.tagline = info_json["tagline"]
	games.append(game_data)

func _populate_test_data():
	var fake_game := GameData.new()
	for i in range(7):
		games.push_back(fake_game)

func _process(delta: float) -> void:
	# Fail safe kiosk exit command
	if Input.is_action_pressed("game_quit") and Input.is_action_pressed("joy_up") and Input.is_action_pressed("game_menu"):
		print("quiting kiosk")
		get_tree().quit()

	if game_running or in_trailer:
		return
	time_since_input += delta
	if time_since_input >= trailer_delay:
		in_trailer = true

func _input(event: InputEvent) -> void:
	time_since_input = 0.0
	# Exit trailer if input
	if in_trailer and not game_running:
		in_trailer = false
		return
	if event.is_echo(): return

	if event.is_action_pressed("game_quit"):
		_quit_game()

	if game_running:
		return
	
	if event.is_action_pressed("ui_left"):
		current_game_index -= 1
		GameIndexChanged.emit(current_game_index, false)
		audio_manager.play_sound(audio_manager.Sounds.SWITCH)
	if event.is_action_pressed("ui_right"):
		current_game_index += 1
		GameIndexChanged.emit(current_game_index, true)
		audio_manager.play_sound(audio_manager.Sounds.SWITCH)
	if event.is_action_pressed("start_game"):
		_start_game()


func _quit_game():
	print("Returning back to kiosk")
	if not game_running:
		return
	OS.kill(current_game_pid)
	current_game_pid = -1
	DisplayServer.window_move_to_foreground()
	GameExited.emit()

func _start_game():
	print("Starting game:" + current_game.name)
	if game_running:
		return
	audio_manager.play_sound(audio_manager.Sounds.START)
	GameStarted.emit()
	current_game_pid = OS.create_process(current_game.exe_path, ["--fullscreen"])

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_APPLICATION_FOCUS_IN:
			if current_game_pid != -1:
				OS.kill(current_game_pid)
				current_game_pid = -1
			GameExited.emit()