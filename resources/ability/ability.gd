extends Upgrade
class_name Ability

var ready : bool = false

var ab_script : AbilityScript = null
var parent : Character = null # parent node

func init(ability:int, parent:Character=null):
	self.ability = ability
	if parent != null: set_parent(parent)
	set_upgrade(effect_lib.get_ability(ability))
	#ab_script = upgrade_lib.get_ability_script(self)

func set_parent(parent:Character):
	self.parent = parent
	ready = true

func physics_update(delta):
	if ready: pass

func on_attack():
	print_debug("FJOIKLNSA")
	if ready: pass
