extends Timer
class_name GameTimer

signal game_timeout

const time_f : String = "%02d:%02d"
const datetime_f : String = "{year}/{month}/{day} {hour}:{minute}"
const clock_format : String = "{Time} {Timezone}"

var total_seconds = 0 : set = set_time
var minutes = 0
var seconds = 0

var text = "00:00"
var label_text = ""
var weather_clock = ""

func _ready():
	timeout.connect(_on_timeout)

func clear() -> void:
	total_seconds = 0
	text = "00:00"
	label_text = ""
	weather_clock = ""

func set_time(t_seconds:int = total_seconds):
	total_seconds = t_seconds
	minutes = int(total_seconds/60)
	seconds = total_seconds%60
	
	text = time_f % [minutes, seconds]
	label_text = text

func _on_timeout():
	#print_debug("AAAAA")
	total_seconds += 1
	set_time()
	# increment weather on interval
	if(Weather.api_success && total_seconds > 0 && total_seconds % Weather.weather_interval == 0):
		Weather.increment()
	
	set_text()
	game_timeout.emit()

func set_text():
	if Weather.api_ready: 
		var index_text = str("\n",Weather.index+1, "/", Weather.api_response.cnt)
		label_text = text + index_text
		
		set_clock()
	
func set_clock():
	# ignore on api response error
	if(!Weather.api_ready): return
	
	# offset game clock proportionally to weather interval and api interval
	var time_offset = Weather.api_interval/Weather.weather_interval * (total_seconds % Weather.weather_interval)
	var txt = get_clock_str(Weather.current_weather().local_dt + time_offset)
	
	weather_clock = txt

func get_clock_str(unix:int) -> String:
	var time = Time.get_datetime_dict_from_unix_time(unix)
	if(time.minute < 10):
		time.minute = str(0, time.minute)
	
	var txt = clock_format.format({
		Time = datetime_f.format(time),
		Timezone = Weather.timezone.abbrev,
	})
	return txt
