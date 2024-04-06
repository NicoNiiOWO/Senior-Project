extends Resource

enum ability_type {NORMAL, SWORD, TORNADO, FIRE, ICE}
static var weather_type = preload("res://libraries/char_lib.gd").weather_type

# path to sprites
static var enemy_sprite = {
	ability_type.NORMAL : "res://assets/waddle dee.tres",
	ability_type.SWORD : "res://assets/blade knight.tres",
	ability_type.TORNADO : "res://assets/twister.tres"
}

# path to attack script
const state_path = "res://entity/enemy/state/"
static var enemy_script : Dictionary = {
	ability_type.NORMAL : null,
	ability_type.SWORD : "e_SwordAttack.gd",
	ability_type.TORNADO : "e_TornadoAttack.gd",
}

# when enemy attacks
# [trigger, distance/time]
enum attack_trigger {TAKEDAMAGE, NEARPLAYER, TIMER}
static var enemy_attack = {
	ability_type.NORMAL : [null],
	ability_type.SWORD : [attack_trigger.TAKEDAMAGE],
	ability_type.TORNADO : [attack_trigger.NEARPLAYER, 150],
}

# spawn rates
# use clear by default
static var spawn_rate = {
	weather_type.CLEAR: {
		ability_type.NORMAL : 20,
		ability_type.SWORD : 30,
		ability_type.TORNADO : 5
	},
	weather_type.WIND : {
		ability_type.TORNADO : 50
	}
}
# stats
static var base_stats = {
	-1 : { # shared
		level = 1,
		atk_size = 1.0,
		dmg_taken = 1.0,
		iframes = 0,
	},
	ability_type.NORMAL : {
		max_exp = 15, # exp given to player
		max_hp = 30,
		atk = 10,
		speed = 100,
	},
	ability_type.SWORD : {
		max_exp = 30,
		max_hp = 50,
		atk = 8,
		speed = 90,
		atk_size = 0.9,
	},
	ability_type.TORNADO : {
		max_exp = 30,
		max_hp = 50,
		atk = 6,
		speed = 110,
		atk_size = 1.1,
	}
}
static var growth_stats = {
	-1 : { # default
		max_hp = 5,
		atk = 2,
		max_exp = 1.15,
		speed = 1,
		atk_size = 0
	},
	ability_type.NORMAL : {
		
	},
	ability_type.SWORD : {
		atk_size = .01
	},
	ability_type.TORNADO : {
		atk_size = .01
	},
}

# return stats for ability, default to normal
static func get_base_stats(ability:int) -> Dictionary:
	var a = ability
	
	# default to normal 
	if ability not in base_stats.keys(): a = 0
	
	# merge with shared stats and overwrite
	var stats = base_stats[-1].duplicate()
	stats.merge(base_stats[a], true)
	#print_debug(stats)
	return stats

static func get_growth_stats(ability:int) -> Dictionary:
	var a = ability
	
	if ability not in growth_stats.keys(): a = 0
	
	var stats = growth_stats[-1].duplicate()
	stats.merge(growth_stats[a], true)
	
	return stats


static func get_sprite(ability) -> SpriteFrames:
	return load(enemy_sprite[ability])

static func get_attack_script(ability) -> Variant:
	if(enemy_script[ability] == null): return null
	return load(state_path + enemy_script[ability])

static func get_attack_trigger(ability) -> Array:
	return enemy_attack[ability]

# return random enemy that can spawn for current weather
static func random_enemy_type(weather_list:Array) -> int:
	var spawn_chance = {}
	
	# for each weather, add spawn rate of each ability
	for w in weather_list:
		# if weather not listed, default to clear
		var temp
		if w in spawn_rate.keys(): temp = w
		else: temp = weather_type.CLEAR
		
		#print_debug("e", spawn_rate[temp])
		for ability in spawn_rate[temp].keys():
			if !spawn_chance.has(ability):
				spawn_chance[ability] = spawn_rate[temp][ability]
			else:
				spawn_chance[ability] += spawn_rate[temp][ability]
	
	# make each entry the sum itself and all previous
	var total=0
	for ability in spawn_chance.keys():
		total += spawn_chance[ability]
		spawn_chance[ability] = total
	
	# pick random int between 1 and total
	# loop through spawn chance until int is < chance
	var random = randi_range(1, total)
	var enemy = -1
	for ability in spawn_chance.keys():
		if random <= spawn_chance[ability] && enemy == -1:
			enemy = ability
	
	return enemy
	
