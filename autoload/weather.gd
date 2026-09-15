extends Node

signal weather_changed(weather: String, temperature: float)

var current_weather: String = "Klart"
var current_temperature: float = 10.0


func _ready() -> void:
	GameTime.day_changed.connect(_on_day_changed)
	generate_daily_weather()


func _on_day_changed(_day: int) -> void:
	generate_daily_weather()


func generate_daily_weather() -> void:
	var season := GameTime.get_season()

	match season:
		"Vår":
			generate_spring_weather()
		"Sommer":
			generate_summer_weather()
		"Høst":
			generate_autumn_weather()
		"Vinter":
			generate_winter_weather()

	weather_changed.emit(current_weather, current_temperature)

	print(
		"Weather: ",
		current_weather,
		" | Temperature: ",
		current_temperature,
		"°C"
	)


func generate_spring_weather() -> void:
	current_temperature = randf_range(2.0, 15.0)

	var roll := randf()

	if roll < 0.45:
		current_weather = "Klart"
	elif roll < 0.80:
		current_weather = "Regn"
	else:
		current_weather = "Overskyet"


func generate_summer_weather() -> void:
	current_temperature = randf_range(10.0, 27.0)

	var roll := randf()

	if roll < 0.55:
		current_weather = "Klart"
	elif roll < 0.80:
		current_weather = "Regn"
	else:
		current_weather = "Overskyet"


func generate_autumn_weather() -> void:
	current_temperature = randf_range(-2.0, 14.0)

	var roll := randf()

	if roll < 0.25:
		current_weather = "Klart"
	elif roll < 0.65:
		current_weather = "Regn"
	elif roll < 0.90:
		current_weather = "Overskyet"
	else:
		current_weather = "Storm"


func generate_winter_weather() -> void:
	current_temperature = randf_range(-18.0, 4.0)

	var roll := randf()

	if roll < 0.25:
		current_weather = "Klart"
	elif roll < 0.65:
		current_weather = "Snø"
	elif roll < 0.90:
		current_weather = "Overskyet"
	else:
		current_weather = "Snøstorm"
