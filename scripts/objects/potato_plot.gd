extends StaticBody2D

enum State {
	EMPTY,
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
@export var harvest_window: int = 2
@export var overripe_days: int = 2
@export var max_harvest: int = 6

var state: State = State.EMPTY
var planted_day: int = 0
var crop_health: float = 100.0
var soil_moisture: float = 70.0
var dry_stress_days: int = 0
var wet_stress_days: int = 0

func _ready() -> void:
	Weather.weather_changed.connect(_on_weather_changed)
	update_visual()


func interact() -> void:
	match state:
		State.EMPTY:
			plant()

		State.READY:
			harvest()
		
		State.OVERRIPE:
			harvest()
		
		State.ROTTEN:
			clear_rotten_crop()

		State.DEAD:
			clear_dead_crop()

		_:
			print_crop_status()


func plant() -> void:
	state = State.PLANTED
	planted_day = GameTime.total_day
	crop_health = 100.0

	print("Potet plantet.")
	print_crop_status()

	update_visual()


func _on_weather_changed(_weather: String, _temperature: float) -> void:
	update_soil_moisture()
	
	if state == State.EMPTY or state == State.ROTTEN or state == State.DEAD:
		return

	apply_weather_effects()
	apply_moisture_effects()

	if crop_health <= 0:
		crop_health = 0
		state = State.DEAD
		print("Potetavlingen døde.")
		update_visual()
		return

	update_growth_stage()
	update_visual()
	print_crop_status()


func apply_weather_effects() -> void:
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
			"Været skadet potetavlingen med ",
			damage,
			" helse."
		)
		
func apply_moisture_effects() -> void:
	if soil_moisture < 35.0:
		dry_stress_days += 1
		wet_stress_days = 0

	elif soil_moisture > 85.0:
		wet_stress_days += 1
		dry_stress_days = 0

	else:
		dry_stress_days = 0
		wet_stress_days = 0

	apply_dry_stress()
	apply_wet_stress()

func apply_dry_stress() -> void:
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
			"Tørke skadet potetavlingen med ",
			damage,
			" helse. Tørre dager: ",
			dry_stress_days
		)

func apply_wet_stress() -> void:
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
			"For våt jord skadet potetavlingen med ",
			damage,
			" helse. Våte dager: ",
			wet_stress_days
		)

func update_growth_stage() -> void:
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

	print("Endring i jord: ", moisture_change)

	soil_moisture += moisture_change
	soil_moisture = clampf(soil_moisture, 0.0, 100.0)

	print(
		"Jordfuktighet: ",
		roundi(soil_moisture),
		"%"
	)


func harvest() -> void:
	var amount := calculate_harvest()

	if amount > 0:
		Inventory.add_item("potato", amount)

	print(
		"Høstet ",
		amount,
		" poteter med ",
		roundi(crop_health),
		"% plantehelse."
	)

	reset_plot()

func calculate_harvest() -> int:
	var amount: int

	if crop_health >= 80:
		amount = max_harvest
	elif crop_health >= 60:
		amount = max(max_harvest - 1, 1)
	elif crop_health >= 40:
		amount = max(max_harvest - 2, 1)
	elif crop_health >= 20:
		amount = max(max_harvest - 4, 1)
	else:
		amount = 0

	if state == State.OVERRIPE:
		var overripe_start := days_to_grow + harvest_window
		var days_overripe := get_crop_age() - overripe_start + 1

		amount -= days_overripe

	return max(amount, 0)


func clear_dead_crop() -> void:
	print("Død potetavling fjernet.")
	reset_plot()
	
func clear_rotten_crop() -> void:
	print("Råtten potetavling fjernet.")
	reset_plot()


func reset_plot() -> void:
	state = State.EMPTY
	planted_day = 0
	crop_health = 100.0
	dry_stress_days = 0
	wet_stress_days = 0
	update_visual()


func get_crop_age() -> int:
	if state == State.EMPTY:
		return 0

	return GameTime.total_day - planted_day


func print_crop_status() -> void:
	print(
		"Potet | Alder: ",
		get_crop_age(),
		" dager | Helse: ",
		roundi(crop_health),
		"% | Jord: ",
		roundi(soil_moisture),
		"% | Tørkestress: ",
		dry_stress_days,
		" | Vått stress: ",
		wet_stress_days,
		" | Stadie: ",
		State.keys()[state]
	)


func update_visual() -> void:
	match state:
		State.EMPTY:
			modulate = Color(0.55, 0.35, 0.20)

		State.PLANTED:
			modulate = Color(0.45, 0.30, 0.20)

		State.SPROUT:
			modulate = Color(0.55, 0.80, 0.35)

		State.YOUNG:
			modulate = Color(0.35, 0.70, 0.25)

		State.MATURE:
			modulate = Color(0.25, 0.60, 0.20)

		State.READY:
			modulate = Color(0.85, 0.75, 0.25)
			
		State.OVERRIPE:
			modulate = Color(0.65, 0.50, 0.15)

		State.ROTTEN:
			modulate = Color(0.20, 0.15, 0.10)

		State.DEAD:
			modulate = Color(0.25, 0.20, 0.15)
