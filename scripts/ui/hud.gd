extends Control

@onready var year_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/YearLabel
@onready var time_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/TimeLabel
@onready var weather_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WeatherLabel
@onready var wood_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WoodLabel


func _ready() -> void:
	Inventory.inventory_changed.connect(update_inventory)
	GameTime.time_changed.connect(update_time)
	Weather.weather_changed.connect(update_weather)

	update_inventory()
	update_time(GameTime.day, GameTime.hour, GameTime.minute)
	update_weather(
		Weather.current_weather,
		Weather.current_temperature
	)


func update_inventory() -> void:
	var wood := Inventory.get_amount("wood")
	wood_label.text = "Ved: " + str(wood)


func update_time(_day: int, _hour: int, _minute: int) -> void:
	year_label.text = "År " + str(GameTime.year)

	time_label.text = (
		GameTime.get_season()
		+ " - Dag "
		+ str(GameTime.get_day_of_season())
		+ " - "
		+ GameTime.get_time_string()
	)


func update_weather(weather: String, temperature: float) -> void:
	weather_label.text = (
		weather
		+ " - "
		+ str(roundi(temperature))
		+ "°C"
	)
