extends Control


var unpause_disable : bool = false

# if paused with key, disable unpausing until released
func _on_gui_pause(disable=false):
	print("eeeee")
	pause()
	if(disable):
		unpause_disable=true

func _input(event):
	if(event.is_action_released("pause")):
		if(unpause_disable):
			unpause_disable = false
		else: unpause()

# show menu and pause
func pause():
	print_debug("pause")
	show()
	get_tree().paused = true

# hide menu and unpause
func unpause():
	print_debug("unpause")
	hide()
	%Settings.hide()
	
	get_tree().paused = false


func _on_settings_button_pressed():
	%Settings.open()

func _on_restart_button_pressed():
	unpause()
