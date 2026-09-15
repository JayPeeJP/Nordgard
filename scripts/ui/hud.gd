extends Control

@onready var wood_label: Label = $InventoryPanel/MarginContainer/VBoxContainer/WoodLabel


func _ready() -> void:
	print("HUD READY")
	print("Wood at start: ", Inventory.get_amount("wood"))

	Inventory.inventory_changed.connect(update_inventory)
	update_inventory()


func update_inventory() -> void:
	var wood := Inventory.get_amount("wood")
	print("HUD UPDATE - Wood: ", wood)
	wood_label.text = "Ved: " + str(wood)
