extends Node

signal weather_changed(weather: String, temperature: float)

var current_weather: String = "Klart"
var current_temperature: float = 10.0
var target_temperature: float = 10.0
var weather_days_remaining: int = 0


func _ready() -> void:
	GameTime.day_changed.connect(_on_day_changed)
	generate_new_weather_period()


func _on_day_changed(_day: int) -> void:
	weather_days_remaining -= 1

	if weather_days_remaining <= 0:
		generate_new_weather_period()
	else:
		update_temperature()

		print(
			"Weather continues: ",
			current_weather,
			" | Temperature: ",
			current_temperature,
			"°C | Days remaining: ",
			weather_days_remaining
		)

		weather_changed.emit(
			current_weather,
			current_temperature
		)

func generate_temperature_target() -> void:
	var season := GameTime.get_season()
	var day_of_season := GameTime.get_day_of_season()

	var progress := float(day_of_season - 1) / float(GameTime.days_per_season - 1)

	match season:
		"Vår":
			var min_temp := lerpf(-5.0, 5.0, progress)
			var max_temp := lerpf(10.0, 20.0, progress)

			target_temperature = randf_range(min_temp, max_temp)

		"Sommer":
			var summer_peak := sin(progress * PI)

			var min_temp := 10.0 + summer_peak * 4.0
			var max_temp := 22.0 + summer_peak * 8.0

			target_temperature = randf_range(min_temp, max_temp)

		"Høst":
			var min_temp := lerpf(7.0, -7.0, progress)
			var max_temp := lerpf(20.0, 7.0, progress)

			target_temperature = randf_range(min_temp, max_temp)

		"Vinter":
			var winter_peak := sin(progress * PI)

			var min_temp := -10.0 - winter_peak * 12.0
			var max_temp := 4.0 - winter_peak * 6.0

			target_temperature = randf_range(min_temp, max_temp)

func generate_new_weather_period() -> void:
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
	
	generate_temperature_target()
	update_temperature()

	weather_days_remaining = get_weather_duration()

	print(
		"New weather period: ",
		current_weather,
		" | Temperature: ",
		current_temperature,
		"°C | Duration: ",
		weather_days_remaining,
		" days"
	)

	weather_changed.emit(
		current_weather,
		current_temperature
	)


func generate_spring_weather() -> void:
	var roll := randf()

	if roll < 0.45:
		current_weather = "Klart"
	elif roll < 0.80:
		current_weather = "Regn"
	else:
		current_weather = "Overskyet"


func generate_summer_weather() -> void:
	var roll := randf()

	if roll < 0.55:
		current_weather = "Klart"
	elif roll < 0.80:
		current_weather = "Regn"
	else:
		current_weather = "Overskyet"


func generate_autumn_weather() -> void:
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
	var roll := randf()

	if roll < 0.25:
		current_weather = "Klart"
	elif roll < 0.65:
		current_weather = "Snø"
	elif roll < 0.90:
		current_weather = "Overskyet"
	else:
		current_weather = "Snøstorm"
	
func get_weather_duration() -> int:
	match current_weather:
		"Klart":
			return randi_range(2, 5)

		"Regn":
			return randi_range(1, 3)

		"Overskyet":
			return randi_range(1, 3)

		"Storm":
			return randi_range(1, 2)

		"Snø":
			return randi_range(1, 4)

		"Snøstorm":
			return randi_range(1, 2)

	return 1

func update_temperature() -> void:
	var difference := target_temperature - current_temperature

	var change := difference * 0.45
	change += randf_range(-2.0, 2.0)

	change = clampf(change, -7.0, 7.0)

	current_temperature += change
