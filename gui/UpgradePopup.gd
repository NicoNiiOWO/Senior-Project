extends Control

#const stats_lib = preload("res://libraries/stats_lib.gd")

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

func _ready():
	make_list()

# make list of selectable upgrades
func make_list(count:int=3):
	var upgrades = upgrade_lib.random_upgrade(count)
	
	print_debug(upgrades, upgrade_lib)
	clear()
	for x in range(upgrades.size()):
		var button = %UpgradeButton.duplicate()
		
		#var text = ""
		#button.text = upgrades[x]
		#for stat in upgrades[x].keys():
			#button.text += stat.capitalize() + " "
		
		button.text = upgrade_lib.get_text(upgrades[x])
		
		button.show()
		
		%UpgradeSelect.add_child(button)

func clear():
	for n in %UpgradeSelect.get_children():
		%UpgradeSelect.remove_child(n)
		n.queue_free()

func pause(pause:bool=true):
	get_tree().paused = pause

func _on_gui_popup(e=1):
	print_debug(e)
	show()
	pause()

func _on_close_button_pressed():
	hide()
	pause(false)
	
	make_list()
