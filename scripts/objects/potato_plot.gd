extends StaticBody2D

enum State {
	EMPTY,
	GROWING,
	READY
}

@export var days_to_grow: int = 4
@export var harvest_amount: int = 4

var state: State = State.EMPTY
var planted_day: int = 0


func _ready() -> void:
	GameTime.day_changed.connect(_on_day_changed)
	update_visual()


func interact() -> void:
	match state:
		State.EMPTY:
			plant()

		State.GROWING:
			print(
				"Poteten vokser. ",
				get_days_remaining(),
				" dager igjen."
			)

		State.READY:
			harvest()


func plant() -> void:
	state = State.GROWING
	planted_day = GameTime.day

	print("Potet plantet på dag ", planted_day)

	update_visual()


func harvest() -> void:
	Inventory.add_item("potato", harvest_amount)

	print("Høstet ", harvest_amount, " poteter.")

	state = State.EMPTY
	planted_day = 0

	update_visual()


func _on_day_changed(_day: int) -> void:
	if state != State.GROWING:
		return

	if get_growth_days() >= days_to_grow:
		state = State.READY

		print("Potetene er klare til høsting!")

		update_visual()


func get_growth_days() -> int:
	if state == State.EMPTY:
		return 0

	return GameTime.day - planted_day


func get_days_remaining() -> int:
	return max(days_to_grow - get_growth_days(), 0)


func update_visual() -> void:
	match state:
		State.EMPTY:
			modulate = Color(0.55, 0.35, 0.20)

		State.GROWING:
			modulate = Color(0.40, 0.75, 0.30)

		State.READY:
			modulate = Color(0.85, 0.75, 0.25)
