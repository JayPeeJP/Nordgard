extends StaticBody2D

@export var health: int = 3
@export var wood_amount: int = 5


func take_hit() -> void:
	health -= 1
	print("Tree hit! Health: ", health)

	if health <= 0:
		chop_down()


func chop_down() -> void:
	Inventory.add_item("wood", wood_amount)

	print("Tree chopped down!")
	queue_free()
