extends Resource
class_name EffectList

const effect_lib = preload("res://libraries/effect_lib.gd")
const category_type = effect_lib.category

var weather_list : Array = []

var size : int = 0 # upgrade count
var upgrade_stat_list : Dictionary = {}
var total_mod : Dictionary = {} # total stat mod

var ability_list : Dictionary = {} # store abilities, key = type

var parent : Character

func init(node:Character) -> EffectList:
	parent = node
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
				if has_upgrade(upgrade):
					upgrade_stat_list[upgrade.type].add_level()
				else:
					upgrade_stat_list[upgrade.type] = upgrade
			_: 
				#print_debug(upgrade.type.x, category_type, category_type.STAT_UPGRADE, upgrade.type.x=category_type.STAT_UPGRADE)
				return
		update_total()
	size+=1

func add_ability(ability:Ability):
	if has_upgrade(ability):
		ability_list[ability.type].add_level()
	else:
		ability_list[ability.type] = ability
		ability.set_parent(parent)

func update_weather():
	if Weather.api_ready:
		set_weather(Weather.current_weather().type)
	
# set weather effect from weather type array
func set_weather(weather_arr:Array):
	var new_weather = []
	for w in weather_arr:
		var eff = Effect.new()
		eff.set_weather(w)
		new_weather.append(eff)

	weather_list = new_weather

func new_stat_upgrade(stat:String, _n:int=1):
	var upgrade = Upgrade.new()
	upgrade.set_stat_upgrade(stat)

	add_upgrade(upgrade)

func add_stat_dict(stats:Dictionary):
	var upgrade = Upgrade.new()
	upgrade.set_stats(stats)

	add_upgrade(upgrade)

func new_ability(ability_type:int):
	var ability = Ability.new()
	ability.init(ability_type, parent)

	add_upgrade(ability)

func update_total():
	update_weather()
	total_mod = get_total_mod()

func get_total_mod(include_weather=true):
	var stat_list = []

	if include_weather:
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

	
# if contains same upgrade type
func has_upgrade(upg:Upgrade) -> bool:
	if (upg is Ability) and (upg.type in ability_list): return true
	if upg.type in upgrade_stat_list: return true
	
	return false

# if has same type, return upgrade
func get_upgrade(upg:Upgrade) -> Upgrade:
	if has_upgrade(upg):
		if upg is Ability: return ability_list[upg.type]
		else: return upgrade_stat_list[upg.type]
	return null

func get_ability_txt() -> String:
	var txt = ""
	for i in ability_list:
		var ability = ability_list[i]
		txt += str(ability.name, " Lvl ", ability.level, "\n")
	
	return txt

func get_upgrade_txt():
	return Stats.get_stats_text(get_total_mod(false), false, true)

# call each ability
func physics_update(delta):
	for i in ability_list:
		
		ability_list[i].physics_update(delta)

func on_attack():
	for i in ability_list:
		ability_list[i].on_attack()
