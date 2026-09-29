extends Crop


func _ready() -> void:
	super._ready()

	GameTime.day_changed.connect(_on_day_changed)

	update_growth_stage()
	update_visual()

	print("CarrotCrop plantet på dag ", planted_day)


func _on_day_changed(_day: int) -> void:
	if state == State.DEAD or state == State.ROTTEN:
		print_crop_status()
		return

	apply_temperature_effects()
	apply_moisture_effects()

	if crop_health <= 0:
		crop_health = 0
		state = State.DEAD

		print("Gulrotavlingen døde.")

		update_visual()
		print_crop_status()
		return

	update_growth_stage()
	update_visual()
	print_crop_status()


func interact() -> void:
	match state:
		State.READY, State.OVERRIPE:
			harvest()

		State.ROTTEN, State.DEAD:
			clear_crop()

		_:
			print_crop_status()


func print_crop_status() -> void:
	var moisture: float = 0.0

	if farm_plot != null:
		moisture = farm_plot.soil_moisture

	print(
		"Gulrot | Alder: ",
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
			modulate = Color(0.60, 0.80, 0.35)
		State.YOUNG:
			modulate = Color(0.40, 0.75, 0.25)
		State.MATURE:
			modulate = Color(0.25, 0.65, 0.20)
		State.READY:
			modulate = Color(0.90, 0.65, 0.20)
		State.OVERRIPE:
			modulate = Color(0.65, 0.45, 0.15)
		State.ROTTEN:
			modulate = Color(0.25, 0.18, 0.08)
		State.DEAD:
			modulate = Color(0.15, 0.12, 0.08)
