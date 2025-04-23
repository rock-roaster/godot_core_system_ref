extends Node


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()
	if event.is_action_pressed(&"ui_cancel"): _on_cancel_pressed()


func _on_accept_pressed() -> void:
	pass


func _on_cancel_pressed() -> void:
	pass
