extends GridContainer

@export var default_icon: Texture2D

var games_directory: String
var current_game_pid: int = -1

func _ready():
	if OS.has_feature("editor"):
		games_directory = ProjectSettings.globalize_path("res://games/")
	else:
		games_directory = OS.get_executable_path().get_base_dir().path_join("games/")
	
	add_theme_constant_override("h_separation", 50)
	add_theme_constant_override("v_separation", 50)
	scan_for_games()

func scan_for_games():
	for child in get_children():
		child.queue_free()
	var dir = DirAccess.open(games_directory)
	if dir:
		dir.list_dir_begin()
		var item_name = dir.get_next()
		while item_name != "":
			var full_path = games_directory.path_join(item_name)
			if dir.current_is_dir() and item_name != "." and item_name != "..":
				_check_folder_for_exe(full_path, item_name)
			item_name = dir.get_next()
	_set_initial_focus()

func _set_initial_focus():
	await get_tree().process_frame
	if get_child_count() > 0:
		var first_button = get_child(0).get_child(0)
		if first_button is Button:
			first_button.grab_focus()

func _check_folder_for_exe(path, folder_name):
	var dir = DirAccess.open(path)
	if not dir: return
	dir.list_dir_begin()
	var exe_path = ""
	var icon_path = ""
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".exe"): exe_path = path.path_join(file)
		if file.begins_with("icon") and (file.ends_with(".png") or file.ends_with(".jpg") or file.ends_with(".webp")):
			icon_path = path.path_join(file)
		file = dir.get_next()
	if exe_path != "": _create_game_card(folder_name, exe_path, icon_path)

func _create_game_card(display_name, exe_path, icon_path):
	var container = VBoxContainer.new()
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(200, 200)
	btn.expand_icon = true
	btn.focus_mode = Control.FOCUS_ALL
	
	if icon_path != "" and FileAccess.file_exists(icon_path):
		var image = Image.load_from_file(icon_path)
		btn.icon = ImageTexture.create_from_image(image)
	else:
		btn.icon = default_icon
	
	var label = Label.new()
	label.text = display_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	btn.pressed.connect(func():
		# Nur starten, wenn nicht schon eins läuft
		if not OS.is_process_running(current_game_pid):
			print("Starte: ", display_name)
			current_game_pid = OS.create_process(exe_path, [])
			# Optional: Launcher minimieren, damit er keine Ressourcen frisst
			# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	)
	
	container.add_child(btn)
	container.add_child(label)
	add_child(container)

func _input(event):
	if event.is_echo(): return

	# DER WICHTIGSTE TEIL:
	# Wenn ein Prozess läuft, ignorieren wir alle Inputs (außer das Beenden-Signal)
	var game_is_active = OS.is_process_running(current_game_pid)

	if event is InputEventJoypadButton and event.pressed:
		# 1. Spiel starten NUR wenn KEIN Spiel läuft
		if event.button_index == 0 and not game_is_active:
			var focused_node = get_viewport().gui_get_focus_owner()
			if focused_node is Button:
				get_viewport().set_input_as_handled()
				focused_node.emit_signal("pressed")
		
		# 2. Spiel beenden (Button 3 / Y) darf IMMER funktionieren
		elif event.button_index == 5:
			if game_is_active:
				get_viewport().set_input_as_handled()
				_kill_running_game()

	# ESC beendet ebenfalls das Spiel, falls eins läuft
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if game_is_active:
			_kill_running_game()

func _kill_running_game():
	if current_game_pid != -1:
		print("Beende externe EXE...")
		OS.kill(current_game_pid)
		current_game_pid = -1
		# Launcher wieder hervorholen, falls er minimiert war
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_move_to_foreground()
