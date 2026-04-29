class_name SerialManager

var serial: GdSerial

func _init() -> void:
	if KioskManager.esp_port.is_empty():
		return
	KioskManager.GameIndexChanged.connect(_on_game_index_changed)
	KioskManager.TrailerExit.connect(_on_trailer_quit)
	KioskManager.TrailerStart.connect(_on_trailer_start)
	serial = GdSerial.new()
	serial.set_port(KioskManager.esp_port)
	serial.set_baud_rate(9600)

func turnOnLight(lightIndex: int):
	print("Turning on light: ", lightIndex)
	if KioskManager.esp_port.is_empty():
		return
	if serial.open():
		serial.writeline("SET" + str(lightIndex))
		serial.close()

func notifyQuit():
	if KioskManager.esp_port.is_empty():
		return
	if serial.open():
		serial.writeline("OFF")
		serial.close()

func _on_game_index_changed(new_index: int, _added: bool):
	turnOnLight(new_index)

func _on_trailer_quit():
	print("Trailer Stop")
	if serial.open():
		serial.writeline("TRAILER_END")
		serial.close()

func _on_trailer_start():
	print("Trailer Start")
	if serial.open():
		serial.writeline("TRAILER_START")
		serial.close()