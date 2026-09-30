extends Node

signal inventory_changed
signal selected_slot_changed(index: int)

const MAX_SLOTS: int = 10

var selected_slot_index: int = 0
var slots: Array[InventorySlot] = []
var is_open: bool = false


func _ready() -> void:
	add_item("axe", 1)
	add_item("hoe", 1)
	add_item("watering_can", 1)
	add_item("shovel", 1)
	add_item("potato", 5)
	add_item("carrot", 15)
	add_item("wood", 20)
	
	update_selected_item()


func add_item(item_id: String, amount: int = 1) -> int:
	var item: ItemData = ItemDatabase.get_item(item_id)

	if item == null:
		print("Ukjent item: ", item_id)
		return amount
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


func get_selected_slot() -> InventorySlot:
	if selected_slot_index < 0 or selected_slot_index >= slots.size():
		return null

	return slots[selected_slot_index]


func get_selected_item() -> ItemData:
	var slot := get_selected_slot()

	if slot == null:
		return null

	return slot.item


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


func select_slot(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS:
		return

	selected_slot_index = index

	update_selected_item()

	print("Valgt hotbar-slot: ", index + 1)

	selected_slot_changed.emit(index)


func update_selected_item() -> void:
	var slot := get_selected_slot()

	if slot == null:
		ToolManager.select_tool(ToolManager.Tool.NONE)
		return

	var item := slot.item

	# Verktøy
	if item.item_type == ItemData.ItemType.TOOL:
		match item.tool_type:
			ItemData.ToolType.AXE:
				ToolManager.select_tool(ToolManager.Tool.AXE)

			ItemData.ToolType.HOE:
				ToolManager.select_tool(ToolManager.Tool.HOE)

			ItemData.ToolType.WATERING_CAN:
				ToolManager.select_tool(ToolManager.Tool.WATERING_CAN)

			ItemData.ToolType.SHOVEL:
				ToolManager.select_tool(ToolManager.Tool.SHOVEL)

			_:
				ToolManager.select_tool(ToolManager.Tool.NONE)

		return

	# Ikke et verktøy
	ToolManager.select_tool(ToolManager.Tool.NONE)

	# Avlinger
	match item.item_id:
		"potato":
			CropManager.select_crop(CropManager.CropType.POTATO)

		"carrot":
			CropManager.select_crop(CropManager.CropType.CARROT)
