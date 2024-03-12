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
	}
]

const city_format = "{name}, {country}, ({lat}, {lon})"
const city_format_us = "{name}, {state}, {country}, ({lat}, {lon})"

var geocode_success : bool = false
var geocode_response : Array


var selected = {
	lat = 0,
	lon = 0,
}

func _ready():
	for i in locations:
		%OptionButton.add_item(i.city)

func open():
	if(Global.api_success):
		selected.lat = Global.api_settings.latitude
		selected.lon = Global.api_settings.longitude
		set_coords(selected.lat, selected.lon)

	visible = true
	
func _on_close_button_pressed():
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

func set_coords(lat, lon):
	selected.lat = lat
	selected.lon = lon
	%LatEdit.text = str(lat)
	%LonEdit.text = str(lon)

func coords_enable(enable=true):
	%LonEdit.editable = enable
	%LatEdit.editable = enable

func _on_city_button_pressed(): 
	geocode_request(%CityText.text)

func geocode_request(text):
	%CityText.editable = false
	%CityList.hide()
	%APIErrorText.hide()
	geocode_success = false
	
	var url = geocode_url.format({City=text,Limit="5",Key=Global.api_settings["api_key"]})
	var request = $HTTPRequest.request(url)
	if request != OK:
		print_debug("geocode error")
		%APIErrorText.text = "Request failed"
		%APIErrorText.show()
	else:
		print_debug("a")

func _on_http_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	print_debug(str(response))
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
			"lat": "%.3f" % city.lat,
			"lon": "%.3f" % city.lon,
			})
		%CityList.add_item(string)
	%CityList.select(0)
	%CityList.show()

func _on_city_list_item_selected(index):
	var selected = geocode_response[index-1]
	print(str(selected))
	set_coords(selected.lat,selected.lon)


func _on_apply_button_pressed():
	save_settings()
	
func save_settings():
	if(%OptionButton.selected == 1):
		set_coords(%LatEdit.text, %LonEdit.text)
	
	# save settings to config
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	
	config.set_value("API", "latitude", selected.lat)
	config.set_value("API", "longitude", selected.lon)
	
	print(config.get_value("API","key"))
	config.set_value("API", "key", config.get_value("API","key"))
	
	var error = config.save("res://config.cfg")
	if error != OK:
		%SaveText.text = "Save error"
		print_debug("save error")
	else: 
		%SaveText.text = "Settings saved"
		print_debug("settings saved")
		settings_changed.emit()
	
