extends PanelContainer

@onready var item_name_label: Label = $MarginContainer/VBoxContainer/ItemNameLabel
@onready var amount_label: Label = $MarginContainer/VBoxContainer/AmountLabel


func set_slot(slot: InventorySlot) -> void:
	item_name_label.text = slot.item.display_name
	amount_label.text = "x" + str(slot.amount)


func clear_slot() -> void:
	item_name_label.text = ""
	amount_label.text = ""
