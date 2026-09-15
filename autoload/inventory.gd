extends Node

signal inventory_changed

var items: Dictionary = {}


func add_item(item_id: String, amount: int = 1) -> void:
	if items.has(item_id):
		items[item_id] += amount
	else:
		items[item_id] = amount

	inventory_changed.emit()

	print("Added ", amount, " ", item_id)
	print("Inventory: ", items)


func get_amount(item_id: String) -> int:
	return items.get(item_id, 0)


func has_item(item_id: String, amount: int = 1) -> bool:
	return get_amount(item_id) >= amount


func remove_item(item_id: String, amount: int = 1) -> bool:
	if not has_item(item_id, amount):
		return false

	items[item_id] -= amount

	if items[item_id] <= 0:
		items.erase(item_id)

	inventory_changed.emit()
	return true
