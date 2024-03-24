extends Control

signal settings_changed()
const geocode_url = "https://api.openweathermap.org/geo/1.0/direct?q={City}&limit={Limit}&appid={Key}"

const locations = [
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

const city_format = "{name}, {country}, ({lat}, {lon})"
const city_format_us = "{name}, {state}, {country}, ({lat}, {lon})"

var geocode_success : bool = false
var geocode_response : Array


var selected = {
	lat = 0,
	lon = 0,
	key = null,
}

func _ready():
	for i in locations:
		%OptionButton.add_item(i.city)
	
	print(Global.api_settings)
	if Global.api_settings.custom_key:
		%KeyToggle.set_pressed(true)

func open():
	if(Global.api_settings.latitude != null && Global.api_settings.longitude != null):
		selected.lat = Global.api_settings.latitude
		selected.lon = Global.api_settings.longitude
		set_coords(selected.lat, selected.lon)

	visible = true
	
func _on_close_button_pressed():
	%SaveText.text = ""
	%SaveText.hide()
	hide()

func _on_option_button_item_selected(index):
	print("e")
	print(index)
	
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

func set_coords(lat:float, lon:float):
	selected.lat = lat
	selected.lon = lon
	%LatEdit.text = str(lat)
	%LonEdit.text = str(lon)

# if key setting is enabled, use input key, else use default
func set_key():
	var key
	if %KeyToggle.button_pressed: 
		key = %KeyEdit.text
	else: 
		key = null
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
	
	var url = geocode_url.format({City=text,Limit="5",Key=selected.key})
	var request = $HTTPRequest.request(url)
	if request != OK:
		print_debug("geocode error")
		%APIErrorText.text = "Request failed"
		%APIErrorText.show()
	else:
		print_debug("a")

func _on_http_request_request_completed(_result, response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	print_debug(str(response))
	# check for error
	if(response_code != 200):
		print_debug(response_code)
		%APIErrorText.text = str("API error ", response_code, ":\n", response.message)
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
	print(str(select))
	set_coords(select.lat,select.lon)

# Save settings when apply button is pressed
func save_settings(change_key:bool = false):
	if(%OptionButton.selected == 1):
		set_coords(%LatEdit.text, %LonEdit.text)
	set_key()
	
	# save settings to config
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	
	# use selected longitude/latitude and key
	config.set_value("API", "latitude", selected.lat)
	config.set_value("API", "longitude", selected.lon)
	config.set_value("API", "key", selected.key)
	config.set_value("API", "custom_key", (selected.key != null))
	
	var error = config.save("res://config.cfg")
	if error != OK:
		%SaveText.text = "Save error"
		print_debug("save error")
	else: 
		%SaveText.text = "Settings saved"
		print_debug("settings saved")
		settings_changed.emit()
	%SaveText.show()
	

func _on_api_key_check_button_toggled(toggled_on):
	%KeyEdit.visible = toggled_on

func _on_api_key_button_pressed():
	Global.api_settings["key"] = %KeyEdit.text
