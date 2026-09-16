extends StaticBody2D

const POTATO_CROP = preload("res://scenes/objects/potato_crop.tscn")

enum SoilState {
	UNTILLED,
	TILLED
}

var soil_state: SoilState = SoilState.UNTILLED
var soil_moisture: float = 70.0
var current_crop: Node2D = null


func _ready() -> void:
	Weather.weather_changed.connect(_on_weather_changed)


func _on_weather_changed(_weather: String, _temperature: float) -> void:
	update_soil_moisture()
	
func _on_crop_harvested() -> void:
	current_crop = null

	print("FarmPlot er klar for ny planting.")
	

func _on_crop_cleared() -> void:
	current_crop = null

	print("FarmPlot er ryddet og klar for ny planting.")


func update_soil_moisture() -> void:
	var temperature := Weather.current_temperature
	var weather := Weather.current_weather

	var moisture_change: float = -5.0

	if temperature > 25.0:
		moisture_change -= 5.0
	elif temperature > 20.0:
		moisture_change -= 2.0

	match weather:
		"Regn":
			moisture_change += 25.0

		"Storm":
			moisture_change += 35.0

		"Snø":
			moisture_change += 5.0

		"Snøstorm":
			moisture_change += 10.0

	soil_moisture += moisture_change
	soil_moisture = clampf(soil_moisture, 0.0, 100.0)

	print(
		"FarmPlot jordfuktighet: ",
		roundi(soil_moisture),
		"%"
	)


func interact() -> void:
	var tool := ToolManager.get_selected_tool()

	if tool == ToolManager.Tool.WATERING_CAN:
		water()
		return

	if tool == ToolManager.Tool.HOE:
		till_soil()
		return

	if soil_state == SoilState.UNTILLED:
		print("Jorden må bearbeides før du kan plante.")
		return

	if current_crop == null:
		plant_crop()
		return

	if current_crop.has_method("interact"):
		current_crop.interact()
		return


func till_soil() -> void:
	if soil_state == SoilState.TILLED:
		print("Jorden er allerede bearbeidet.")
		return

	soil_state = SoilState.TILLED

	print("Jorden ble bearbeidet.")

	update_visual()


func plant_crop() -> void:
	if soil_state != SoilState.TILLED:
		print("Jorden må bearbeides først.")
		return

	if current_crop != null:
		print("Det står allerede en plante her.")
		return

	var crop := POTATO_CROP.instantiate()

	crop.farm_plot = self
	crop.harvested.connect(_on_crop_harvested)
	crop.cleared.connect(_on_crop_cleared)

	$CropPosition.add_child(crop)

	current_crop = crop

	print("Potet plantet i FarmPlot.")

	print("Potet plantet i FarmPlot.")


func print_soil_status() -> void:
	print(
		"Jord: ",
		SoilState.keys()[soil_state],
		" | Fuktighet: ",
		roundi(soil_moisture),
		"%"
	)


func update_visual() -> void:
	match soil_state:
		SoilState.UNTILLED:
			modulate = Color.WHITE

		SoilState.TILLED:
			modulate = Color(0.55, 0.35, 0.20)


func water() -> void:
	if soil_state != SoilState.TILLED:
		print("Jorden må bearbeides før den kan vannes.")
		return

	var water_amount: float = 20.0

	soil_moisture += water_amount
	soil_moisture = clampf(soil_moisture, 0.0, 100.0)

	print(
		"Jorden ble vannet. Jordfuktighet: ",
		roundi(soil_moisture),
		"%"
	)
