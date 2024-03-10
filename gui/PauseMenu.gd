extends Control

# unpause when pressed and released
# prevents pausing immediately after
var released = false
func _input(event):
	if released && event.is_action_released("pause"):
		released = false
		unpause()
	else: if event.is_action_released("pause"):
		released = true
	

# hide menu and unpause
func unpause():
	print_debug("unpause")
	hide()
	get_tree().paused = false
