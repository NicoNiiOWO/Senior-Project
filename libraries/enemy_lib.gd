extends Resource

static var weather_type = preload("res://libraries/effects.gd").weather_type
enum ability_type {NORMAL, SWORD}


static var enemy_sprite = {
	ability_type.NORMAL : "res://assets/waddle dee.tres",
	ability_type.SWORD : "res://assets/blade knight.tres",
}

static var spawn_rate = {
	weather_type.CLEAR: {
		ability_type.NORMAL : 50,
		ability_type.SWORD : 30,
	}
}

static func get_sprite(ability):
	return load(enemy_sprite[ability])

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
	
