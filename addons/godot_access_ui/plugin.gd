@tool
extends EditorPlugin


func _enter_tree() -> void:
	print("GodotAccessUI 0.1: Enabled")
	print("* NVDA integration: ", ClassDB.class_exists("NVDA"))

func _exit_tree() -> void:
	print("GodotAccessUI 0.1: Disabled")
