extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_changed(day: int)

@export var real_seconds_per_game_minute: float = 1.0

var day: int = 1
var hour: int = 8
var minute: int = 0

var _timer: float = 0.0


func _process(delta: float) -> void:
	_timer += delta

	if _timer >= real_seconds_per_game_minute:
		_timer -= real_seconds_per_game_minute
		advance_minute()


func advance_minute() -> void:
	minute += 1

	if minute >= 60:
		minute = 0
		hour += 1

	if hour >= 24:
		hour = 0
		day += 1
		day_changed.emit(day)

	time_changed.emit(day, hour, minute)


func get_time_string() -> String:
	return "%02d:%02d" % [hour, minute]
