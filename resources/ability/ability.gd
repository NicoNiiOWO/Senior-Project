extends Upgrade
class_name Ability

var ready : bool = false

var parent : Character = null # parent node

func init(ability:int, parent:Character=null):
	self.ability = ability
	if parent != null: set_parent(parent)
	set_upgrade(effect_lib.get_ability(ability))
	level_changed.connect(on_level_changed)

func set_parent(parent:Character):
	self.parent = parent
	ready = parent.is_node_ready()
	
	# if parent is not loaded, set ready when parent is loaded
	if !ready: parent.ready.connect(set_ready)

func set_ready():
	ready = true


# override:
func physics_update(delta): if ready: pass

func on_attack(): if ready: pass

func on_level_changed(): pass

func get_next_lvl_text(lvl=self.level):
	var text = str("Level ", lvl+1)
	if lvl == 0:
		text += "\n" + upgrade_lib.get_text(self)
	
	return text
