class_name WorldItem
extends StaticBody2D

@export var item_data: ItemData
@export var amount: int = 1
@export var world_icon_size: float = 24.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	update_visual()


func interact() -> void:
	if item_data == null:
		print("WorldItem mangler ItemData.")
		return

	var remaining := Inventory.add_item(
		item_data.item_id,
		amount
	)

	var picked_up := amount - remaining

	if picked_up > 0:
		print(
			"Plukket opp ",
			picked_up,
			" ",
			item_data.display_name.to_lower(),
			"."
		)

	amount = remaining

	if amount <= 0:
		queue_free()
	else:
		print(
			"Ikke plass til resten. ",
			amount,
			" ligger igjen."
		)


func setup(new_item_data: ItemData, new_amount: int) -> void:
	item_data = new_item_data
	amount = new_amount

	update_visual()


func update_visual() -> void:
	if item_data == null:
		return

	if item_data.icon == null:
		return

	sprite.texture = item_data.icon

	var texture_size := item_data.icon.get_size()
	var largest_side := maxf(texture_size.x, texture_size.y)

	if largest_side > 0:
		var scale_factor := world_icon_size / largest_side
		sprite.scale = Vector2.ONE * scale_factor
