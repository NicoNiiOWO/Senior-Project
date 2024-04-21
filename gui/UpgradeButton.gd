extends Button

signal upgrade_pressed(upgrade:Upgrade)
var upgrade:Upgrade

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")
#const icons = preload("res://libraries/upgrade_lib.gd").get_icons

func set_upgrade(upg:Upgrade):
	upgrade = upg
	
	%AbilityText.set_texture(upgrade.icons["text"])
	%AbilityIcon.set_texture(upgrade.icons["icon"])
	$AbilityIcon.show()

func _on_pressed():
	upgrade_pressed.emit(upgrade)
