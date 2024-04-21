extends Resource
class_name EffectList

const effect_lib = preload("res://libraries/effect_lib.gd")
const category_type = effect_lib.category
const stats_type = effect_lib.stats_type
const ability_type = effect_lib.ability_type

var weather_list : Array = []

var size : int = 0 # upgrade count
var upgrade_stat_list : Dictionary = {}
var total_mod : Dictionary = {} # total stat mod

var ability_list : Dictionary = {} # store nodes, key = ability type
var listNode : Node = null # node in parent, store ability nodes

var parent : Character

func init(node:Character) -> EffectList:
	parent = node
	listNode = parent.get_node_or_null("AbilityList")
	return self

func clear_weather():
	weather_list = []

# add to lists based on type. if duplicate, increment
func add_upgrade(upgrade:Upgrade):
	#print_debug("AA", upgrade.type.x == category_type.UPGRADE)
	#print_debug(typeof(upgrade.type.x)," ", typeof(category_type.UPGRADE))
	if upgrade is Ability:
		add_ability(upgrade)
	else:
		match upgrade.type.x as int:
			category_type.WEATHER:
				set_weather([upgrade])

			category_type.STAT_UPGRADE:
				print_debug("AAAAAAAAAAAAAAAAAA")
				if upgrade.type in upgrade_stat_list:
					upgrade_stat_list[upgrade.type].add_level()
				else:
					upgrade_stat_list[upgrade.type] = upgrade
			_: 
				#print_debug(upgrade.type.x, category_type, category_type.STAT_UPGRADE, upgrade.type.x=category_type.STAT_UPGRADE)
				return
	size+=1
	
	
	update_total()

func add_ability(ability:Ability):
	if listNode == null:
		listNode = Node.new()
		parent.add_child(listNode)
	
	if ability.type in ability_list:
		ability_list[ability.type].add_level()
	else:
		var node = ability.get_node()
		listNode.add_child(node)
		ability_list[ability.type] = node

# set weather effect from weather array
func set_weather(weather_arr:Array):
	var new_weather = {}
	for w in weather_arr:
		var eff = Effect.new()
		eff.set_weather(w)
		new_weather[w] = eff

	weather_list = new_weather
	update_total()

func new_stat_upgrade(stat:String, _n:int=1):
	var type = effect_lib.get_upgrade(stat).type

	var upgrade = Upgrade.new()
	upgrade.set_stat_upgrade(stat)

	add_upgrade(upgrade)

func add_stat_dict(stats:Dictionary):
	var upgrade = Upgrade.new()
	upgrade.set_stats(stats)

	add_upgrade(upgrade)

func new_ability(ability_type:int):
	var ability = Ability.new()
	ability.set_ability(ability_type)

	add_upgrade(ability)

func update_total():
	total_mod = get_total_mod()

func get_total_mod():
	var stat_list = []

	for eff in weather_list:
		stat_list.append(eff.stats)
	for eff in upgrade_stat_list:
		stat_list.append(upgrade_stat_list[eff].stats)
	
	var total = {}
	for stats in stat_list:
		total = effect_lib.combine_stat_dict(total, stats)
	
	return total

func print():
	print_debug("Size: ", size, "\nWeather: ", weather_list, "\nStat Upgrade: ",upgrade_stat_list,"\nTotal: ", total_mod)
