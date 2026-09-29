class_name InventorySlot
extends RefCounted

var item: ItemData
var amount: int = 0


func _init(
	new_item: ItemData = null,
	new_amount: int = 0
) -> void:
	item = new_item
	amount = new_amount


func is_empty() -> bool:
	return item == null or amount <= 0


func can_add(item_data: ItemData) -> bool:
	if is_empty():
		return true

	if item.item_id != item_data.item_id:
		return false

	return amount < item.max_stack


func get_available_space() -> int:
	if is_empty():
		return 0

	return item.max_stack - amount
