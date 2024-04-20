extends Resource
class_name Effect

const effect_lib = preload("res://libraries/effect_lib.gd")
var category_list = effect_lib.category

var isWeather : bool = false # if weather effect
var hasStats
@export var type : Vector2 = Vector2(0,-1) # (category, stat/ability type)

@export var count : int = 0 # amount
@export var stat_base : Dictionary = {}
var stats : Dictionary = {} # base * count


var node : Node = null

# get from effect_lib
func set_effect(eff_data:Dictionary):
	type = eff_data.type
	isWeather = (type.x == category_list.WEATHER)

	hasStats = eff_data.has_stats
	count = eff_data.count
	node = eff_data.node

	if hasStats:
		set_stats(eff_data.stats, eff_data.count)

# func init(set_type:Vector2, set_mods:Dictionary={}):
# 	type = set_type
# 	stat_base = set_mods
# 	stat_mods = set_mods
# 	count = 1
	
# 	if type.x != category_list.ABILITY_UPGRADE:
# 		set_stats(set_mods)

func set_stats(base_stats:Dictionary, n:int=1):
	stat_base = base_stats
	count = n
	stat_multiply(n)

func set_weather(weatherType:int):
	set_effect(effect_lib.get_weather(weatherType))

func add(n:int = 1):
	count += n
	stat_multiply(count + n)

# set base stats * number
func stat_multiply(n:int=count):
	var stats = {}
	for stat in stat_base:
		stats[stat] = stat_base[stat] * n
	self.stats = stats