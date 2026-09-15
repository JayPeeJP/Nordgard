extends Control

@onready var time_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/TimeLabel
@onready var wood_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WoodLabel


func _ready() -> void:
	Inventory.inventory_changed.connect(update_inventory)
	GameTime.time_changed.connect(update_time)

	update_inventory()
	update_time(GameTime.day, GameTime.hour, GameTime.minute)


func update_inventory() -> void:
	var wood := Inventory.get_amount("wood")
	wood_label.text = "Ved: " + str(wood)


func update_time(day: int, _hour: int, _minute: int) -> void:
	time_label.text = "Dag " + str(day) + " - " + GameTime.get_time_string()
