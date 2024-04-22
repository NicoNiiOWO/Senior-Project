extends Resource
class_name Effect

signal level_changed()

const effect_lib = preload("res://libraries/effect_lib.gd")
var category_list = effect_lib.category

var isWeather : bool = false # if weather effect
var hasStats
@export var type : Vector2 = Vector2(0,-1) # (category, stat/ability type)

@export var level : int = 0 # amount
@export var stat_base : Dictionary = {}
var stats : Dictionary = {} # base * count

# get from effect_lib
func set_effect(eff_data:Dictionary):
	type = eff_data.type
	isWeather = (type.x == category_list.WEATHER)

	hasStats = eff_data.has_stats
	level = eff_data.count

	if hasStats:
		set_stats(eff_data.stats, eff_data.count)

func set_stats(base_stats:Dictionary, n:int=1):
	stat_base = base_stats
	level = n
	stat_multiply(n)

func set_weather(weatherType:int):
	set_effect(effect_lib.get_weather(weatherType))

func add_level(n:int = 1):
	level += n
	stat_multiply(level)
	level_changed.emit()

# set base stats * number
func stat_multiply(n:int=level):
	var stats = {}
	for stat in stat_base:
		stats[stat] = stat_base[stat] * n
	self.stats = stats
