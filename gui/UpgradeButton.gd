extends Button

signal upgrade_pressed(upgrade:Dictionary)
var upgrade:Upgrade

func set_upgrade(upg:Upgrade):
	upgrade = upg
	
	#if upgrade is from ability:
	#$AbilityIcon.show()

func _on_pressed():
	upgrade_pressed.emit(upgrade)
