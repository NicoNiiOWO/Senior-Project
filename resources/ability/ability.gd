extends Upgrade
class_name Ability

var ready : bool = false

var parent : Character = null # parent node

# base stats for each ability
const ab_base_stats = {
	1 : {
		atk_mod = 0.2, # multiply by parent atk stat
		size = 1.2
	}
	
}
const ab_growth_stats = {
	1: {
		atk_mod = 0.01,
		size = 0.05
	}
	
}
var ability_stats = {}

func init(ability:int, parent:Character=null):
	self.ability = ability
	if parent != null: set_parent(parent)
	set_upgrade(effect_lib.get_ability(ability))
	level_changed.connect(on_level_changed)
	
	update_stats()

func set_parent(parent:Character):
	self.parent = parent
	ready = parent.is_node_ready()
	
	# if parent is not loaded, set ready when parent is loaded
	if !ready: parent.ready.connect(set_ready)

func set_ready():
	ready = true

func update_stats(): # calculate stats
	if ability in ab_base_stats:
		var stats = ab_base_stats[ability].duplicate()
		
		for stat in ab_growth_stats[ability]:
			stats[stat] += level * ab_growth_stats[ability][stat]
		ability_stats = stats

# override:
func physics_update(delta): if ready: pass

func on_attack(): if ready: pass

func on_level_changed(): 
	update_stats()

func get_next_lvl_text(lvl=self.level):
	var text = str("Level ", lvl+1)
	if lvl == 0:
		text += "\n1" + upgrade_lib.get_text(self)
	else:
		text += "\n" + upgrade_lib.get_stat_text(self.ab_growth_stats[ability])
	
	return text
