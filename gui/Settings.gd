extends Control

signal settings_changed()
signal settings_closed()

const geocode_url = "https://api.openweathermap.org/geo/1.0/direct?q={City}&limit={Limit}&appid={Key}"

@onready var locations = Config.location_preset

const city_format = "{name}, {country}, ({lat}, {lon})"
const city_format_us = "{name}, {state}, {country}, ({lat}, {lon})"

var geocode_success : bool = false
var geocode_response : Array


var selected = {
	latitude = 0,
	longitude = 0,
	key = null,
	use_key = false,
}

@onready var gui = owner # main gui node

func _ready():
	for i in locations:
		%OptionButton.add_item(i.city)
	
	if Config.api_settings.use_key:
		selected.use_key = true
		%KeyToggle.set_pressed(true)
		
	%MasterVolume.volume = Config.volume.master
	%BGMVolume.volume = Config.volume.bgm
	%SFXVolume.volume = Config.volume.sfx

func open():
	if(Config.api_settings.latitude != null && Config.api_settings.longitude != null):
		selected.latitude = Config.api_settings.latitude
		selected.longitude = Config.api_settings.longitude
		set_coords(selected.latitude, selected.longitude)

	visible = true
	%CloseButton.grab_focus()
	
func _on_close_button_pressed():
	%SaveText.text = ""
	%SaveText.hide()
	hide()
	settings_closed.emit()

func _on_option_button_item_selected(index):
	match index:
		0: # Enter City
			coords_enable(false)
			%CityEdit.show()
			%CityList.visible = geocode_success
		1: # Manual Edit
			coords_enable(true)
			%CityEdit.hide()
			%CityList.hide()
		_: # Preset
			coords_enable(false)
			%CityEdit.hide()
			%CityList.hide()
			
			set_coords(locations[index-3].lat, locations[index-3].lon)

func select_preset(i:int):
	set_coords(locations[i].lat,locations[i].lon)

func set_coords(lat:float, lon:float):
	selected.latitude = lat
	selected.longitude = lon
	%LatEdit.text = str(lat)
	%LonEdit.text = str(lon)

# set use_key to toggle state, set key to input if not empty
func set_key():
	selected.use_key = %KeyToggle.button_pressed
	
	var key = %KeyEdit.text
	if key == "": key = null
	selected.key = key

func coords_enable(enable:bool=true):
	%LonEdit.editable = enable
	%LatEdit.editable = enable

func geocode_request(text:String = %CityText.text):
	# disable editing until request is complete
	%CityText.editable = false
	%CityList.hide()
	%APIErrorText.hide()
	geocode_success = false
	
	set_key()
	
	var url = geocode_url.format({City=text,Limit="5",Key=Config.api_settings.key})
	
	print_debug(url)
	var request = $HTTPRequest.request(url)
	if request != OK:
		print_debug("geocode error")
		%APIErrorText.text = "Request failed"
		%APIErrorText.show()
	else:
		print_debug("a")

# handle geocode request
func _on_http_request_request_completed(_result, response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	print_debug(str(response))
	# check for error
	if(response_code != 200):
		print_debug("error ", response_code)
		var txt = ""
		match response_code:
			400: txt = "No location found" 
			_: txt = str("API error ", response_code)
		if response != null: txt += str(":\n", response.message)
		%APIErrorText.text = txt
		
		%APIErrorText.show()
	else:
		geocode_success = true
		geocode_response = response
		geocode_list()
	%CityText.editable = true

# make option list from geocode api
func geocode_list():
	%CityList.clear()
	%CityList.add_item("Select City:")
	%CityList.set_item_disabled(0,true)
	
	# add each response as an option
	for city in geocode_response:
		var format = city_format
		var state = ""
		if city.has("state"): 
			format = city_format_us
			state = city["state"]
			
		var string = format.format({
			"name":city.name,
			"state":state,
			"country":city.country,
			"lat": "%.4f" % city.lat,
			"lon": "%.4f" % city.lon,
			})
		%CityList.add_item(string)
	%CityList.select(0)
	%CityList.show()

func _on_city_list_item_selected(index:int):
	var select = geocode_response[index-1]
	
	set_coords(select.lat,select.lon)

# Save settings when apply button is pressed
func save_settings():
	if(%OptionButton.selected == 1):
		set_coords(%LatEdit.text as float, %LonEdit.text as float)
	set_key()
	
	var vol_master = %MasterVolume.value
	var vol_bgm = %BGMVolume.value
	var vol_sfx = %SFXVolume.value
	
	Config.set_volume(vol_master, vol_bgm, vol_sfx)
	Config.set_api_settings(selected)
	
	if Config.save() != OK:
		%SaveText.text = "Save error"
		print_debug("save error")
	else: 
		%SaveText.text = "Settings saved"
		print_debug("settings saved")
		settings_changed.emit()
	%SaveText.show()
	await get_tree().create_timer(3.0).timeout
	%SaveText.hide()

func _on_api_key_check_button_toggled(toggled_on):
	%KeyEdit.visible = toggled_on

func _on_api_key_button_pressed():
	Config.api_settings["key"] = %KeyEdit.text
