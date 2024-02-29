extends Node

enum char_type {PLAYER, ENEMY}

var level_timer = 0

var player_stats = {
	level = 1,
	max_exp = 0,
	exp = 0,
	max_hp = 0,
	hp = 0,
	atk = 0,
	speed = 0
}

var api_response_code = 0
var api_response = {
	list = [],
}
var index = 0 # current index in list

var weather = {
	weather = "",
	temp = 0,
	datetime = ""
}
