extends Control

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

var popup_active:bool = false
var upgrades:Array

var player : Character = null

func popup(upgrade_list:Array):
	popup_active = true
	make_list(upgrade_list)
	show()
	popup_pause()
	%UpgradeSelect.get_child(0).grab_focus()

# make list of selectable upgrades
func make_list(upgrade_list:Array):
	
	player = owner.player
	#upgrades = upgrade_lib.random_upgrade(count)
	
	#print_debug(upgrades, upgrade_lib)
	clear()
	for i in range(upgrade_list.size()):
		var upg = upgrade_list[i]
		var button = %UpgradeButton.duplicate()
		
		button.set_upgrade(upg)
		
		# if player has ability, set text to next level
		if upg is Ability and player != null and player.has_upgrade(upg):
			#print_debug(owner.player != null, " ", owner.player.has_upgrade(upg))
			var u = player.get_upgrade(upg)
			button.text = u.get_next_lvl_text()
		else:
			button.text = upgrade_lib.get_text(upg)
		
		button.show()
		
		# increase columns every 5
		if (i+1) % 5 == 0:
			%UpgradeSelect.columns += 1
			
		%UpgradeSelect.add_child(button)

# clear list
func clear():
	%UpgradeSelect.columns = 1
	for n in %UpgradeSelect.get_children():
		%UpgradeSelect.remove_child(n)
		n.queue_free()

func popup_pause(enable:bool=true):
	get_tree().paused = enable

func _on_gui_popup(upgrade_list:Array=[]):
	popup(upgrade_list)
	

func _on_upgrade_button_pressed(upgrade:Upgrade):
	owner.player.add_upgrade(upgrade)
	
	_on_close_button_pressed()

func _on_close_button_pressed():
	popup_active = false
	hide()
	popup_pause(false)
