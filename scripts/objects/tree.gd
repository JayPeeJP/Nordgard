extends StaticBody2D

const WORLD_ITEM_SCENE := preload(
	"res://scenes/objects/world_item.tscn"
)

@export var health: int = 3
@export var wood_amount: int = 5

var wood_item: ItemData = preload(
	"res://data/items/wood.tres"
)


func take_hit() -> void:
	if ToolManager.get_selected_tool() != ToolManager.Tool.AXE:
		print("Du trenger en øks for å hugge treet.")
		return

	health -= 1
	print("Tree hit! Health: ", health)

	if health <= 0:
		chop_down()


func chop_down() -> void:
	var remaining := Inventory.add_item(
		wood_item.item_id,
		wood_amount
	)

	if remaining > 0:
		drop_item(wood_item, remaining)

	print("Tree chopped down!")
	queue_free()


func drop_item(item_data: ItemData, amount: int) -> void:
	var world_item := WORLD_ITEM_SCENE.instantiate()

	get_parent().add_child(world_item)

	world_item.global_position = global_position
	world_item.setup(item_data, amount)
