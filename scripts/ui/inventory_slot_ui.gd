extends PanelContainer

@onready var item_icon: TextureRect = $MarginContainer/SlotContent/ItemIcon
@onready var amount_label: Label = $MarginContainer/SlotContent/AmountLabel
@onready var shortcut_label: Label = $MarginContainer/SlotContent/ShortcutLabel
@onready var selection_border: Panel = $SelectionBorder

var slot_index: int = -1
var is_selected: bool = false


func clear_slot() -> void:
	item_icon.texture = null
	amount_label.text = ""
	tooltip_text = ""


func setup(index: int) -> void:
	slot_index = index

	if index == 9:
		shortcut_label.text = "0"
	else:
		shortcut_label.text = str(index + 1)


func set_selected(selected: bool) -> void:
	is_selected = selected
	selection_border.visible = selected


func set_slot(slot: InventorySlot) -> void:
	item_icon.texture = slot.item.icon

	if slot.amount > 1:
		amount_label.text = str(slot.amount)
	else:
		amount_label.text = ""

	tooltip_text = slot.item.display_name
