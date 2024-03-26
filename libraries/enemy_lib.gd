extends Resource

static var weather_type = preload("res://libraries/effects.gd").weather_type
enum ability_type {NORMAL, SWORD, TORNADO, FIRE, ICE}

static var enemy_sprite = {
	ability_type.NORMAL : "res://assets/waddle dee.tres",
	ability_type.SWORD : "res://assets/blade knight.tres",
	ability_type.TORNADO : "res://assets/twister.tres"
}

const state_path = "res://entity/enemy/state/"
static var enemy_script : Dictionary = {
	ability_type.NORMAL : null,
	ability_type.SWORD : "e_SwordAttack.gd",
	ability_type.TORNADO : "e_TornadoAttack.gd",
}

static var spawn_rate = {
	weather_type.CLEAR: {
		ability_type.NORMAL : 50,
		ability_type.SWORD : 30,
		ability_type.TORNADO : 20
	},
	weather_type.WIND : {
		ability_type.TORNADO : 50
	}
}

static var base_stats = {
	ability_type.NORMAL : {
		level = 1,
		max_exp = 15, # exp given to player
		max_hp = 30,
		atk = 10,
		speed = 100,
		atk_size = 1,
		dmg_taken = 1,
	},
	ability_type.SWORD : {
		level = 1,
		max_exp = 30,
		max_hp = 50,
		atk = 8,
		speed = 100,
		atk_size = 1,
		dmg_taken = 1,
	}
}
static var growth_stats = {
	ability_type.NORMAL : {
		max_hp = 5,
		atk = 2,
		max_exp = 1.15, # multiply
		speed = 2
	},
	ability_type.SWORD : {
		max_hp = 5,
		atk = 2,
		max_exp = 1.15, # multiply
		speed = 2
	},
}

# return stats for ability, default to normal
static func get_base_stats(ability:int) -> Dictionary:
	if ability in base_stats.keys():
		return base_stats[ability]
	else: return base_stats[0]

static func get_growth_stats(ability:int) -> Dictionary:
	if ability in growth_stats.keys():
		return growth_stats[ability]
	else: return growth_stats[0]


static func get_sprite(ability) -> SpriteFrames:
	return load(enemy_sprite[ability])

static func get_attack_script(ability) -> Variant:
	if(enemy_script[ability] == null): return null
	return load(state_path + enemy_script[ability])

# return random enemy that can spawn for current weather
static func random_enemy_type(weather_list:Array) -> int:
	var weather = weather_list
	
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
	print_debug("eeeeee ", random, spawn_chance)
	print_debug("enemy ", enemy)

	return enemy
	
