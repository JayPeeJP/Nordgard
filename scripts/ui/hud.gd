extends Control

@onready var year_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/YearLabel
@onready var time_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/TimeLabel
@onready var weather_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WeatherLabel
@onready var wood_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WoodLabel
@onready var tool_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/ToolLabel


func _ready() -> void:
	Inventory.inventory_changed.connect(update_inventory)
	GameTime.time_changed.connect(update_time)
	Weather.weather_changed.connect(update_weather)
	ToolManager.tool_changed.connect(update_tool)

	update_inventory()
	update_time(GameTime.day, GameTime.hour, GameTime.minute)
	update_weather(
		Weather.current_weather,
		Weather.current_temperature
	)
	update_tool(ToolManager.get_selected_tool())


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


func update_tool(tool: ToolManager.Tool) -> void:
	match tool:
		ToolManager.Tool.NONE:
			tool_label.text = "Verktøy: Ingen"

		ToolManager.Tool.AXE:
			tool_label.text = "Verktøy: Øks"

		ToolManager.Tool.HOE:
			tool_label.text = "Verktøy: Hakke"

		ToolManager.Tool.WATERING_CAN:
			tool_label.text = "Verktøy: Vannkanne"

		ToolManager.Tool.SHOVEL:
			tool_label.text = "Verktøy: Spade"
