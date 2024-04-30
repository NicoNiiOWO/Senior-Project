extends HSlider
class_name VolumeSlider

@export var bus_index = -1
@export var volume = 0.8 : set=set_vol

## Called when the node enters the scene tree for the first time.
func _ready():
	set_vol(volume)

func _on_value_changed(val):
	volume = val

func set_vol(val):
	value = val
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))

