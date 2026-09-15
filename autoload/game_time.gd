extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_changed(day: int)
signal season_changed(season: String)
signal year_changed(year: int)

@export var real_seconds_per_game_minute: float = 0.01
@export var days_per_season: int = 2

var day: int = 1
var hour: int = 8
var minute: int = 0
var year: int = 1
var total_day: int = 1

var seasons: Array[String] = [
	"Vår",
	"Sommer",
	"Høst",
	"Vinter"
]

var _timer: float = 0.0


func _process(delta: float) -> void:
	_timer += delta

	while _timer >= real_seconds_per_game_minute:
		_timer -= real_seconds_per_game_minute
		advance_minute()


func advance_minute() -> void:
	minute += 1

	if minute >= 60:
		minute = 0
		hour += 1

	if hour >= 24:
		hour = 0
		advance_day()

	time_changed.emit(day, hour, minute)


func advance_day() -> void:
	var previous_season := get_season()

	day += 1
	total_day += 1

	var days_per_year := days_per_season * seasons.size()

	if day > days_per_year:
		day = 1
		year += 1
		year_changed.emit(year)

	var current_season := get_season()

	if current_season != previous_season:
		season_changed.emit(current_season)

	day_changed.emit(day)


func get_season_index() -> int:
	return int((day - 1) / days_per_season)


func get_season() -> String:
	return seasons[get_season_index()]


func get_day_of_season() -> int:
	return ((day - 1) % days_per_season) + 1


func get_time_string() -> String:
	return "%02d:%02d" % [hour, minute]
