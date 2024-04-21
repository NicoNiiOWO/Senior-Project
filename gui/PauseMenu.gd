extends Control

signal unpaused()

var input_disable : bool = false

# if paused with key, disable unpausing until released
var input_released : bool = true
func _on_gui_pause(release:bool=true):
	#print("eeeee")
	pause()
	if(!release):
		input_released=false

func _input(event):
	if not input_disable:
		if(event.is_action_released("pause")):
			if(!input_released):
				input_released = true
			else: unpause()

# show menu and pause
func pause():
	print_debug("pause")
	show()
	%PauseRestartButton.grab_focus()
	get_tree().paused = true

# hide menu and unpause
func unpause():
	print_debug("unpause")
	hide()
	%Settings.hide()
	
	unpaused.emit()
	get_tree().paused = false


func _on_settings_button_pressed():
	%Settings.open()

func _on_restart_button_pressed():
	unpause()

func _on_settings_settings_closed():
	if visible: %PauseRestartButton.grab_focus()
