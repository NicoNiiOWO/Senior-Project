extends Control

#const stats_lib = preload("res://libraries/stats_lib.gd")

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

var upgrades:Array

func _ready():
	#make_list()
	pass


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

func pause(enable:bool=true):
	get_tree().paused = enable

func _on_gui_popup(e=[]):
	print_debug(e)
	make_list(e)
	show()
	pause()
	%UpgradeSelect.get_child(0).grab_focus()

func _on_close_button_pressed():
	hide()
	pause(false)
	
	#make_list()


func _on_upgrade_button_pressed(upgrade:Upgrade):
	print_debug(upgrade)
	owner.player.add_upgrade(upgrade)
	
	_on_close_button_pressed()
