extends Node

enum char_type {PLAYER, ENEMY}

var level_timer = {
	minutes = 0,
	seconds = 0,
	total_seconds = 0
}

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

var weather = {}

var timezone = Time.get_time_zone_from_system()

var weather_interval # time between game weather change in seconds
var api_interval # time between api response entries
