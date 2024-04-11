extends Button

signal upgrade_pressed(upgrade:Dictionary)
var upgrade:Dictionary = {}

func _on_pressed():
	upgrade_pressed.emit(upgrade)
