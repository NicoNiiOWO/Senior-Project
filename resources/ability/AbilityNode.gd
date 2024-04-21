extends Node2D
class_name AbilityNode

var upgrade : Ability = null
var passive : bool = false
var active : bool = false

func set_ability(upg:Ability):
	upgrade = upg

func add_level():
	upgrade.add_level()
	print_debug("level ", upgrade.level)

func _ready():
	if owner is Character:
		print_debug("AAAAAAAAAA")

func attack():
	print_debug("AAAAAA")
