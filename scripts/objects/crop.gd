class_name Crop
extends Node2D

const WORLD_ITEM_SCENE := preload(
	"res://scenes/objects/world_item.tscn"
)

signal harvested
signal cleared

enum State {
	PLANTED,
	SPROUT,
	YOUNG,
	MATURE,
	READY,
	OVERRIPE,
	ROTTEN,
	DEAD
}

@export var days_to_grow: int = 8
@export var harvest_window: int = 3
@export var overripe_days: int = 2
@export var max_harvest: int = 6
@export var crop_name: String = ""
@export var harvest_item_id: String = ""

var farm_plot: Node = null
var planted_day: int = 0

var crop_health: float = 100.0
var dry_stress_days: int = 0
var wet_stress_days: int = 0

var state: State = State.PLANTED


func _ready() -> void:
	planted_day = GameTime.total_day


func get_crop_age() -> int:
	return GameTime.total_day - planted_day


func apply_temperature_effects() -> void:
	var temperature := Weather.current_temperature
	var damage: float = 0.0

	if temperature < -5.0:
		damage = 25.0
	elif temperature < 0.0:
		damage = 15.0
	elif temperature > 30.0:
		damage = 10.0
	elif temperature > 25.0:
		damage = 5.0

	if damage > 0:
		crop_health -= damage

		print(
			"Temperaturen skadet planten med ",
			damage,
			" helse. Temperatur: ",
			roundi(temperature),
			"°C"
		)


func apply_moisture_effects() -> void:
	if farm_plot == null:
		return

	var soil_moisture: float = farm_plot.soil_moisture

	if soil_moisture < 35.0:
		dry_stress_days += 1
		wet_stress_days = 0

	elif soil_moisture > 85.0:
		wet_stress_days += 1
		dry_stress_days = 0

	else:
		dry_stress_days = 0
		wet_stress_days = 0

	apply_dry_stress(soil_moisture)
	apply_wet_stress(soil_moisture)


func apply_dry_stress(soil_moisture: float) -> void:
	if dry_stress_days < 2:
		return

	var damage: float = 0.0

	if soil_moisture <= 10.0:
		damage = 20.0
	elif soil_moisture <= 20.0:
		damage = 10.0
	elif soil_moisture < 35.0:
		damage = 5.0

	if damage > 0:
		crop_health -= damage

		print(
			"Tørke skadet planten med ",
			damage,
			" helse."
		)


func apply_wet_stress(soil_moisture: float) -> void:
	if wet_stress_days < 3:
		return

	var damage: float = 0.0

	if soil_moisture >= 95.0:
		damage = 10.0
	elif soil_moisture > 85.0:
		damage = 5.0

	if damage > 0:
		crop_health -= damage

		print(
			"For våt jord skadet planten med ",
			damage,
			" helse."
		)


func calculate_harvest() -> int:
	var amount: int

	if crop_health >= 80.0:
		amount = max_harvest
	elif crop_health >= 60.0:
		amount = max(max_harvest - 1, 1)
	elif crop_health >= 40.0:
		amount = max(max_harvest - 2, 1)
	elif crop_health >= 20.0:
		amount = max(max_harvest - 4, 1)
	else:
		amount = 0

	if state == State.OVERRIPE:
		var overripe_start := days_to_grow + harvest_window
		var days_overripe := get_crop_age() - overripe_start + 1

		amount -= days_overripe

	return max(amount, 0)


func clear_crop() -> void:
	if state != State.ROTTEN and state != State.DEAD:
		print("Denne planten skal ikke ryddes bort.")
		return

	print("Den døde/råtne planten ble ryddet bort.")

	cleared.emit()
	queue_free()


func drop_harvest(amount: int) -> void:
	var item_data: ItemData = ItemDatabase.get_item(harvest_item_id)

	if item_data == null:
		print("Ukjent harvest item: ", harvest_item_id)
		return

	var world_item := WORLD_ITEM_SCENE.instantiate()

	get_tree().current_scene.add_child(world_item)

	world_item.global_position = global_position + Vector2(24, 0)
	world_item.setup(item_data, amount)

	print(
		"Ikke plass i inventory. ",
		amount,
		" ",
		item_data.display_name.to_lower(),
		" ligger igjen på bakken."
	)


func harvest() -> void:
	if state != State.READY and state != State.OVERRIPE:
		print("Avlingen er ikke klar for høsting.")
		return

	var amount := calculate_harvest()

	if amount > 0:
		var remaining := Inventory.add_item(
			harvest_item_id,
			amount
		)

		if remaining > 0:
			drop_harvest(remaining)

		print(
			"Du høstet ",
			amount,
			" ",
			crop_name.to_lower(),
			"."
		)
	else:
		print("Avlingen var ikke brukbar.")

	harvested.emit()
	queue_free()


func update_growth_stage() -> void:
	if state == State.DEAD:
		return

	var age := get_crop_age()

	var overripe_start := days_to_grow + harvest_window
	var rotten_start := overripe_start + overripe_days

	if age >= rotten_start:
		state = State.ROTTEN
	elif age >= overripe_start:
		state = State.OVERRIPE
	elif age >= days_to_grow:
		state = State.READY
	elif age >= 6:
		state = State.MATURE
	elif age >= 4:
		state = State.YOUNG
	elif age >= 2:
		state = State.SPROUT
	else:
		state = State.PLANTED
