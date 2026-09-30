extends Node

var items: Dictionary = {
	"potato": preload("res://data/items/potato.tres"),
	"carrot": preload("res://data/items/carrot.tres"),
	"wood": preload("res://data/items/wood.tres"),
	"axe": preload("res://data/items/axe.tres"),
	"hoe": preload("res://data/items/hoe.tres"),
	"watering_can": preload("res://data/items/watering_can.tres"),
	"shovel": preload("res://data/items/shovel.tres")
}

func get_item(item_id: String) -> ItemData:
	if not items.has(item_id):
		return null

	return items[item_id]
