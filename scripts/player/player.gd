extends CharacterBody2D

@export var speed: float = 200.0

@onready var interaction_area: Area2D = $InteractionArea


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

	if event.is_action_pressed("tool_none"):
		ToolManager.select_tool(ToolManager.Tool.NONE)

	elif event.is_action_pressed("tool_axe"):
		ToolManager.select_tool(ToolManager.Tool.AXE)

	elif event.is_action_pressed("tool_hoe"):
		ToolManager.select_tool(ToolManager.Tool.HOE)

	elif event.is_action_pressed("tool_watering_can"):
		ToolManager.select_tool(ToolManager.Tool.WATERING_CAN)

	elif event.is_action_pressed("tool_shovel"):
		ToolManager.select_tool(ToolManager.Tool.SHOVEL)


func interact() -> void:
	print("E pressed!")

	var bodies := interaction_area.get_overlapping_bodies()
	print("Bodies found: ", bodies.size())

	for body in bodies:
		print("Found: ", body.name)

		if body == self:
			continue

		if body.has_method("interact"):
			print("Calling interact on: ", body.name)
			body.interact()
			return

		if body.has_method("take_hit"):
			print("Calling take_hit on: ", body.name)
			body.take_hit()
			return
