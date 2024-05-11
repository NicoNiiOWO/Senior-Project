extends HSlider
class_name VolumeSlider

@export var bus_index = -1
@export var volume = 0.5 : set=set_vol

func _on_value_changed(val):
	volume = val

func set_vol(val):
	value = val
	if bus_index < AudioServer.bus_count:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))

