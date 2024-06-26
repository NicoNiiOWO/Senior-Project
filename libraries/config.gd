extends Node

signal loaded

# API variables
const location_preset = [
	{
		city = "Brooklyn, New York",
		lat = 40.6526006,
		lon = -73.9497211,
		
	},
	{
		city = "Tampa, Florida",
		lat = 27.9477595,
		lon = -82.45844,
	},
	{
		city = "Los Angeles, California",
		lat = 34.0536909,
		lon = -118.242766,
	},
	{
		city = "Tokyo, JP",
		lat = 35.6828387,
		lon = 139.7594549,
	}
]

const default_vol ={
	master = 0.5,
	bgm = 0.5,
	sfx = 0.5
}
const default_api = {
	latitude=location_preset[0].lat,
	longitude=location_preset[0].lon,
	key=null,
	use_key=false,
}
const default_display = {
	scale_mode = 1,
	scale_aspect = 4,
	zoom = 1,
}
var randomize_bgm = true
var volume = default_vol.duplicate()
var api_settings = default_api.duplicate()
var display = default_display.duplicate()

var auto_upgrade : bool = true : 
	set(x):
		auto_upgrade = x
		settings.Gameplay.auto_upgrade = x

var settings = {
	Sound = {
		volume = self.volume,
		randomize_bgm = self.randomize_bgm,
	},
	API = self.api_settings,
	Gameplay = {
		auto_upgrade = true,
	},
	Display = self.display
}

func clear_api() -> void:
	api_settings = {
		latitude=null,
		longitude=null,
		key=null,
		use_key=false,
	}

func set_zoom(x):
	display.zoom = x
	if Global.player != null:
		Global.player.set_zoom(x)

func set_coords_dict(settings:Dictionary):
	set_coords(settings.latitude, settings.longitude)

func set_coords(lat,lon):
	api_settings.latitude = lat
	api_settings.longitude = lon

func set_api_settings(settings:Dictionary):
	# if use_key is not provided, set to true if key is set
	var use_key = settings.use_key
	if settings.use_key == null: use_key = (settings.key != null)
	
	api_settings.latitude = settings.latitude
	api_settings.longitude = settings.longitude
	if settings.key != null: api_settings.key = settings.key
	api_settings.use_key = use_key

func set_volume(master=0.8, bgm=0.8, sfx=0.8):
	volume.master = master
	volume.bgm = bgm
	volume.sfx = sfx
	apply_volume()

func set_display(mode, aspect, apply=false):
	settings.Display.scale_mode = mode
	settings.Display.scale_aspect = aspect
	
	#if apply:
		#get_tree().root.content_scale_mode = mode
		#get_tree().root.content_scale_aspect = aspect

func set_volume_dict(vol:Dictionary):
	set_volume(vol.master, vol.bgm, vol.sfx)

func apply_volume(enabled=true):
	if not enabled: set_volume(0,0,0)
	AudioServer.set_bus_volume_db(0, linear_to_db(volume.master))
	
	if AudioServer.bus_count == 3:
		AudioServer.set_bus_volume_db(1, linear_to_db(volume.bgm))
		AudioServer.set_bus_volume_db(2, linear_to_db(volume.sfx))

func load_default() -> Error:
	set_api_settings(default_api.duplicate())
	set_volume_dict(default_vol.duplicate())
	display = default_display.duplicate()
	set_zoom(1)
	
	randomize_bgm = true
	auto_upgrade = true
	
	
	loaded.emit()
	return save()

# load from file
func load_config() -> Dictionary:
	# set api settings from config
	var config = ConfigFile.new()
	
	# load file
	if config.load("user://config.cfg") != OK:
		# if not loaded, load and save default
		load_default()
	else:
		# set settings
		randomize_bgm = config.get_value("Sound", "random_bgm", true)
		for setting in config.get_section_keys("Volume"):
			volume[setting] = config.get_value("Volume", setting, .5)
		for setting in config.get_section_keys("API"):
			api_settings[setting] = config.get_value("API", setting)
		
		auto_upgrade = config.get_value("Gameplay", "auto_upgrade", false)
		for setting in config.get_section_keys("Display"):
			display[setting] = config.get_value("Display", setting)
	
	# set default api key if not in config
	if (api_settings.key == null):
		api_settings.key = load("res://api_key.gd").key
	else:
		api_settings.use_key = true
	
	loaded.emit()
	return api_settings

# save loaded values
func save() -> Error:
	var config = ConfigFile.new()
	config.load("user://config.cfg")
	
	config.set_value("Sound", "random_bgm", randomize_bgm)
	for setting in volume:
		config.set_value("Volume", setting, volume[setting])
	
	# use selected longitude/latitude and key
	config.set_value("API", "latitude", api_settings.latitude)
	config.set_value("API", "longitude", api_settings.longitude)
	
	config.set_value("API", "use_key", api_settings.use_key)
	if api_settings.use_key:
		config.set_value("API", "key", api_settings.key)
		
	
	for setting in settings.Display:
		config.set_value("Display", setting, settings.Display[setting])
	
	for setting in settings.Gameplay:
		config.set_value("Gameplay", setting, settings.Gameplay[setting])
	
	return config.save("user://config.cfg")
