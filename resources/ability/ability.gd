extends Upgrade
class_name Ability

var ready : bool = false

var parent : Character = null # parent node

# base stats for each ability
const ab_base_stats = {
	1 : {
		duration = 0.5,
		speed = 800,
		atk_scale = 0.2, # multiply by parent atk stat
		size = 1.2
	},
	2: {
		duration = -1,
		speed = 400,
		atk_scale = 0.1,
		size = 1
	}
}
const ab_growth_stats = {
	1: {
		atk_scale = 0.01,
		size = 0.05
	},
	2: {
		atk_scale = 0.01,
		size = 0.05
	}
}
var ability_stats = {}

func init(ability_type:int, parent_char:Character=null):
	ability = ability_type
	if parent_char != null: set_parent(parent_char)
	set_upgrade(effect_lib.get_ability(ability))
	level_changed.connect(on_level_changed)
	
	update_stats()

# if parent is not loaded, set ready when parent is loaded
func set_parent(parent_char:Character):
	parent = parent_char

	if parent.is_node_ready(): set_ready()
	else: parent.ready.connect(set_ready)

# call level_changed on load
func set_ready():
	ready = true
	level_changed.emit()

# calculate stats
func update_stats(): 
	if ability in ab_base_stats:
		ability_stats = ab_base_stats[ability].duplicate()
		
		for stat in ab_growth_stats[ability]:
			ability_stats[stat] += level * ab_growth_stats[ability][stat]

# return attack with damage and size
func init_attack(scn:PackedScene) -> Attack:
	var atk = scn.instantiate()
	atk.source = parent.type
	atk.damage = parent.stats.atk * ability_stats.atk_scale
	atk.size = ability_stats.size
	atk.duration = ability_stats.duration
	atk.speed = ability_stats.speed
	
	return atk

# override:
func physics_update(_delta): if ready: pass

func on_attack(): if ready: pass

func on_level_changed(): 
	update_stats()

func get_next_lvl_text(lvl=self.level):
	var txt = str("Level ", lvl+1)
	if lvl == 0:
		txt += "\n1" + upgrade_lib.get_text(self)
	else:
		txt += "\n" + upgrade_lib.get_stat_text(self.ab_growth_stats[ability])
	
	return txt

