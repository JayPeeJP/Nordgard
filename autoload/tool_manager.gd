extends Node

signal tool_changed(tool: Tool)

enum Tool {
	NONE,
	AXE,
	HOE,
	WATERING_CAN,
	SHOVEL
}

var selected_tool: Tool = Tool.NONE


func select_tool(tool: Tool) -> void:
	selected_tool = tool

	print("Valgt verktøy: ", Tool.keys()[selected_tool])

	tool_changed.emit(selected_tool)


func get_selected_tool() -> Tool:
	return selected_tool
