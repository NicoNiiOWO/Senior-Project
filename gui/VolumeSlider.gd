extends HSlider
class_name VolumeSlider

@export var bus_index = -1

#func set_bus(bus_name):
	#bus = bus_name
	#bus_index = AudioServer.get_bus_index(bus)

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_value_changed(value)

func _on_value_changed(val):
	#print_debug(bus_index, " ", bus, " ", AudioServer.get_bus_index(bus))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))
