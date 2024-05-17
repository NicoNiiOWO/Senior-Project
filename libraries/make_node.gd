extends Resource

enum item_types{HEAL,UPGRADE}

const player_scn : PackedScene = preload("res://entity/player.tscn")
const enemy_scn : PackedScene = preload("res://entity/enemy/enemy.tscn")
const item_scn : PackedScene = preload("res://entity/item.tscn")

static func new_item(type:int=-1):
	var item = item_scn.instantiate()
	
	if type == -1: # set random type
		type = randi_range(0,1)
		item.item_type = type
	return item

static func new_enemy(level:int, position:Vector2, target:Node2D=null, ability:int=-1):
	var enemy = enemy_scn.instantiate()
	enemy.gain_level(level-1) # increase level
	if ability != -1:
		enemy.init_ability(ability)
	
	enemy.set_deferred("position", position)
	enemy.set_target_node(target)
	
	if is_instance_of(target,Player):
		enemy.set_player(target)
	
	return enemy

static func new_player(level:int=1):
	var player = player_scn.instantiate()
	if level > 1: player.gain_level(level-1)
	
	return player
