class_name ItemData
extends Resource

enum ItemType {
	RESOURCE,
	SEED,
	TOOL,
	FOOD
}

enum ToolType {
	NONE,
	AXE,
	HOE,
	WATERING_CAN,
	SHOVEL
}

@export var item_id: String = ""
@export var display_name: String = ""
@export var max_stack: int = 99
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.RESOURCE
@export var tool_type: ToolType = ToolType.NONE
