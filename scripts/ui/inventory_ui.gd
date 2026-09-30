extends PanelContainer

const SLOT_SCENE := preload(
	"res://scenes/ui/inventory_slot_ui.tscn"
)

@onready var slot_grid: GridContainer = $MarginContainer/VBoxContainer/SlotGrid

var slot_uis: Array = []


func _ready() -> void:
	create_slots()

	Inventory.inventory_changed.connect(update_inventory)
	Inventory.selected_slot_changed.connect(update_selected_slot)

	update_inventory()
	update_selected_slot(Inventory.selected_slot_index)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_1"):
		Inventory.select_slot(0)
	elif event.is_action_pressed("hotbar_2"):
		Inventory.select_slot(1)
	elif event.is_action_pressed("hotbar_3"):
		Inventory.select_slot(2)
	elif event.is_action_pressed("hotbar_4"):
		Inventory.select_slot(3)
	elif event.is_action_pressed("hotbar_5"):
		Inventory.select_slot(4)
	elif event.is_action_pressed("hotbar_6"):
		Inventory.select_slot(5)
	elif event.is_action_pressed("hotbar_7"):
		Inventory.select_slot(6)
	elif event.is_action_pressed("hotbar_8"):
		Inventory.select_slot(7)
	elif event.is_action_pressed("hotbar_9"):
		Inventory.select_slot(8)
	elif event.is_action_pressed("hotbar_0"):
		Inventory.select_slot(9)


func create_slots() -> void:
	for i in range(Inventory.MAX_SLOTS):
		var slot_ui := SLOT_SCENE.instantiate()

		slot_grid.add_child(slot_ui)
		slot_ui.setup(i)
		slot_uis.append(slot_ui)


func update_inventory() -> void:
	for i in range(slot_uis.size()):
		if i < Inventory.slots.size():
			slot_uis[i].set_slot(Inventory.slots[i])
		else:
			slot_uis[i].clear_slot()


func update_selected_slot(index: int) -> void:
	for i in range(slot_uis.size()):
		slot_uis[i].set_selected(i == index)
