extends Node


func _ready() -> void:
	System.config_manager.load_config()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()
	if event.is_action_pressed(&"ui_cancel"): _on_cancel_pressed()


func _on_accept_pressed() -> void:
	System.config_manager.save_config()


func _on_cancel_pressed() -> void:
	System.config_manager.set_value("game", "language", "zh_CN")
