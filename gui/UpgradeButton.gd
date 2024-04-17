extends Button

signal upgrade_pressed(upgrade:Upgrade)
var upgrade:Upgrade

const icons = preload("res://libraries/upgrade_lib.gd").ability_icons

func set_upgrade(upg:Upgrade):
	upgrade = upg
	
	set_texture(upg.ability)

func set_texture(ability:int=0):
	if ability in icons.keys():
		%AbilityText.set_texture(icons[ability]["text"])
		%AbilityIcon.set_texture(icons[ability]["icon"])
		$AbilityIcon.show()
	else:
		$AbilityIcon.hide()

func _on_pressed():
	upgrade_pressed.emit(upgrade)
	#print(upgrade.stats)
