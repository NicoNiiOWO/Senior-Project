extends Control

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

var popup_active:bool = false
var upgrades:Array

func popup(upgrades:Array):
	popup_active = true
	make_list(upgrades)
	show()
	popup_pause()
	%UpgradeSelect.get_child(0).grab_focus()

# make list of selectable upgrades
func make_list(upgrades:Array):
	#upgrades = upgrade_lib.random_upgrade(count)
	
	#print_debug(upgrades, upgrade_lib)
	clear()
	for x in range(upgrades.size()):
		var button = %UpgradeButton.duplicate()
		
		button.set_upgrade(upgrades[x])
		button.text = upgrades[x].text
		
		button.show()
		
		%UpgradeSelect.add_child(button)

# clear list
func clear():
	for n in %UpgradeSelect.get_children():
		%UpgradeSelect.remove_child(n)
		n.queue_free()

func popup_pause(enable:bool=true):
	get_tree().paused = enable

func _on_gui_popup(upgrades=[]):
	popup(upgrades)
	

func _on_upgrade_button_pressed(upgrade:Upgrade):
	print_debug(upgrade)
	owner.player.add_upgrade(upgrade)
	
	_on_close_button_pressed()

func _on_close_button_pressed():
	popup_active = false
	hide()
	popup_pause(false)
