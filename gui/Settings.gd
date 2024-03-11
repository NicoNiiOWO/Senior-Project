extends Control

const geocode_url = "https://api.openweathermap.org/geo/1.0/direct?q={City}&limit={Limit}&appid={Key}"

func open():
	if(Global.api_success):
		%LongitudeEdit.placeholder_text = str(Global.api_settings.longitude)
		%LatitudeEdit.placeholder_text = str(Global.api_settings.latitude)
	visible = true
	
func _on_close_button_pressed():
	hide()

func _ready():
	pass
	#%OptionButton.get_popup().id_pressed.connect(_on_menu_button_pressed)

func _on_option_button_item_selected(index):
	print("e")
	print(index)
	
	print(geocode_url.format({City="aaaa",Key="23104",Limit=Global.api_settings["api_key"]}) )
	#match id:
		#0: do_something()
		#1: do_something_else()
