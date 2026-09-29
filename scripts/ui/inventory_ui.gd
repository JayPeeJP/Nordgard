extends PanelContainer

const SLOT_SCENE := preload(
	"res://scenes/ui/inventory_slot_ui.tscn"
)

@onready var slot_grid: GridContainer = $MarginContainer/VBoxContainer/SlotGrid

var slot_uis: Array = []


func _ready() -> void:
	create_slots()

	Inventory.inventory_changed.connect(update_inventory)

	update_inventory()

	Inventory.is_open = false
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()


func create_slots() -> void:
	for i in range(Inventory.MAX_SLOTS):
		var slot_ui := SLOT_SCENE.instantiate()

		slot_grid.add_child(slot_ui)
		slot_uis.append(slot_ui)


func toggle_inventory() -> void:
	Inventory.is_open = not Inventory.is_open
	visible = Inventory.is_open


func update_inventory() -> void:
	for i in range(slot_uis.size()):
		if i < Inventory.slots.size():
			slot_uis[i].set_slot(Inventory.slots[i])
		else:
			slot_uis[i].clear_slot()
