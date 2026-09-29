extends Node

signal inventory_changed

const MAX_SLOTS: int = 10

var slots: Array[InventorySlot] = []
var is_open: bool = false

var item_database: Dictionary = {
	"potato": preload("res://data/items/potato.tres"),
	"carrot": preload("res://data/items/carrot.tres"),
	"wood": preload("res://data/items/wood.tres")
}


func _ready() -> void:
	add_item("potato", 5)
	add_item("carrot", 15)
	add_item("wood", 160)


func add_item(item_id: String, amount: int = 1) -> int:
	if not item_database.has(item_id):
		print("Ukjent item: ", item_id)
		return amount

	var item: ItemData = item_database[item_id]
	var remaining := amount

	# Fyll eksisterende stacks først
	for slot in slots:
		if slot.item.item_id != item_id:
			continue

		if slot.amount >= item.max_stack:
			continue

		var space := item.max_stack - slot.amount
		var to_add := mini(space, remaining)

		slot.amount += to_add
		remaining -= to_add

		if remaining <= 0:
			inventory_changed.emit()
			return 0

	# Lag nye stacks
	while remaining > 0 and slots.size() < MAX_SLOTS:
		var to_add := mini(item.max_stack, remaining)

		slots.append(
			InventorySlot.new(item, to_add)
		)

		remaining -= to_add

	inventory_changed.emit()

	return remaining


func get_amount(item_id: String) -> int:
	var total := 0

	for slot in slots:
		if slot.item.item_id == item_id:
			total += slot.amount

	return total


func has_item(item_id: String, amount: int = 1) -> bool:
	return get_amount(item_id) >= amount


func remove_item(item_id: String, amount: int = 1) -> bool:
	if not has_item(item_id, amount):
		return false

	var remaining := amount

	for i in range(slots.size() - 1, -1, -1):
		var slot := slots[i]

		if slot.item.item_id != item_id:
			continue

		var to_remove := mini(slot.amount, remaining)

		slot.amount -= to_remove
		remaining -= to_remove

		if slot.amount <= 0:
			slots.remove_at(i)

		if remaining <= 0:
			break

	inventory_changed.emit()
	return true
