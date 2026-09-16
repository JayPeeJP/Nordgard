extends Node2D

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

var state: State = State.PLANTED
var planted_day: int = 0
var farm_plot: Node = null
var crop_health: float = 100.0

var dry_stress_days: int = 0
var wet_stress_days: int = 0


func _ready() -> void:
	planted_day = GameTime.total_day

	GameTime.day_changed.connect(_on_day_changed)

	update_growth_stage()
	update_visual()

	print(
		"PotatoCrop plantet på dag ",
		planted_day
	)


func _on_day_changed(_day: int) -> void:
	if state == State.DEAD or state == State.ROTTEN:
		print_crop_status()
		return

	apply_temperature_effects()
	apply_moisture_effects()

	if crop_health <= 0:
		crop_health = 0
		state = State.DEAD

		print("Potetavlingen døde.")

		update_visual()
		print_crop_status()
		return

	update_growth_stage()
	update_visual()
	print_crop_status()


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
			"Temperaturen skadet PotatoCrop med ",
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
			"Tørke skadet PotatoCrop med ",
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
			"For våt jord skadet PotatoCrop med ",
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

	print("Den døde/råtne potetplanten ble ryddet bort.")

	cleared.emit()
	queue_free()


func get_crop_age() -> int:
	return GameTime.total_day - planted_day


func harvest() -> void:
	if state != State.READY and state != State.OVERRIPE:
		print("Potetene er ikke klare for høsting.")
		return

	var amount := calculate_harvest()

	if amount > 0:
		Inventory.add_item("potato", amount)

		print(
			"Du høstet ",
			amount,
			" poteter."
		)
	else:
		print("Avlingen var ikke brukbar.")

	harvested.emit()
	queue_free()


func interact() -> void:
	match state:
		State.READY, State.OVERRIPE:
			harvest()

		State.ROTTEN, State.DEAD:
			clear_crop()

		_:
			print_crop_status()


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


func print_crop_status() -> void:
	var moisture: float = 0.0

	if farm_plot != null:
		moisture = farm_plot.soil_moisture

	print(
		"PotatoCrop | Alder: ",
		get_crop_age(),
		" dager | Helse: ",
		roundi(crop_health),
		"% | Jord: ",
		roundi(moisture),
		"% | Tørkestress: ",
		dry_stress_days,
		" | Vått stress: ",
		wet_stress_days,
		" | Stadie: ",
		State.keys()[state]
	)


func update_visual() -> void:
	match state:
		State.PLANTED:
			modulate = Color(0.45, 0.30, 0.15)

		State.SPROUT:
			modulate = Color(0.55, 0.75, 0.35)

		State.YOUNG:
			modulate = Color(0.30, 0.70, 0.25)

		State.MATURE:
			modulate = Color(0.20, 0.60, 0.20)

		State.READY:
			modulate = Color(0.85, 0.75, 0.25)
		
		State.OVERRIPE:
			modulate = Color(0.65, 0.50, 0.15)

		State.ROTTEN:
			modulate = Color(0.25, 0.18, 0.08)

		State.DEAD:
			modulate = Color(0.15, 0.12, 0.08)
