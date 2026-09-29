extends PanelContainer

@onready var item_icon: TextureRect = $MarginContainer/SlotContent/ItemIcon
@onready var amount_label: Label = $MarginContainer/SlotContent/AmountLabel


func set_slot(slot: InventorySlot) -> void:
	item_icon.texture = slot.item.icon

	if slot.amount > 1:
		amount_label.text = str(slot.amount)
	else:
		amount_label.text = ""


func clear_slot() -> void:
	item_icon.texture = null
	amount_label.text = ""
