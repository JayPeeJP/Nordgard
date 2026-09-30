extends Node

signal crop_changed(crop: CropType)

enum CropType {
	POTATO,
	CARROT
}

var selected_crop: CropType = CropType.POTATO

var crop_data := {
	CropType.POTATO: {
		"name": "Potet",
		"item_id": "potato",
		"scene": preload("res://scenes/objects/potato_crop.tscn")
	},

	CropType.CARROT: {
		"name": "Gulrot",
		"item_id": "carrot",
		"scene": preload("res://scenes/objects/carrot_crop.tscn")
	}
}


func get_crop_data_by_item_id(item_id: String) -> Dictionary:
	for data in crop_data.values():
		if data["item_id"] == item_id:
			return data

	return {}


func select_crop(crop: CropType) -> void:
	selected_crop = crop

	var data := get_selected_crop_data()
	print("Valgt avling: ", data["name"])

	crop_changed.emit(selected_crop)


func get_selected_crop_data() -> Dictionary:
	return crop_data[selected_crop]
