extends Resource

enum item_types{HEAL,UPGRADE}

const player_scn : PackedScene = preload("res://entity/player.tscn")
const enemy_scn : PackedScene = preload("res://entity/enemy/enemy.tscn")
const item_scn : PackedScene = preload("res://entity/item.tscn")

static func new_item(type:int=-1):
	var new_item = item_scn.instantiate()
	
	if type == -1: # set random type
		type = randi_range(0,1)
		new_item.item_type = type
	if type == item_types.UPGRADE:
		new_item.popup = true
	return new_item

static func new_enemy(level:int, position:Vector2, target:Node2D=null, type:int=0):
	var new_enemy = enemy_scn.instantiate()
	new_enemy.gain_level(level-1) # increase level
	
	new_enemy.set_deferred("position", position)
	new_enemy.set_target_node(target)
	
	if is_instance_of(target,Player):
		new_enemy.set_player(target)
	
	return new_enemy

static func new_player(level:int=1):
	var player = player_scn.instantiate()
	if level > 1: player.gain_level(level-1)
	
	return player
