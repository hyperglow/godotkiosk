extends Control

@onready var portList: Label = $VBoxContainer/PortList

var manager: GdSerialManager
var serial : GdSerial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# manager = GdSerialManager.new()
	# manager.data_received.connect(_on_data)
	# manager.port_disconnected.connect(_on_disconnect)
	# var ports: Dictionary = manager.list_ports()
	# print("Ports:", ports)
	# portList.text = JSON.stringify(ports)
	# if manager.open("/dev/ttyUSB0", 9600, 1000):
	# 	print("Connected to esp")
	# 	manager.write("/dev/ttyUSB0", var_to_bytes("on\n\r"))
	serial = GdSerial.new()
	
	serial.set_port("/dev/ttyUSB0")
	serial.set_baud_rate(9600)
	

var time_last_toggle = 0
var on = false

func _process(delta):
	if time_last_toggle >= 5:
		if serial.open():
			serial.writeline("off" if on else "on")
			serial.close()
			on = !on
		time_last_toggle = 0
	time_last_toggle += delta
	# This triggers the signals above
	# manager.poll_events()
	pass

func _on_data(port: String, data: PackedByteArray):
	print("Data from ", port, ": ", data.get_string_from_utf8())

func _on_disconnect(port: String):
	print("Lost connection to ", port)
