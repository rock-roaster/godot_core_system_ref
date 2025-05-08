extends Node


@onready var label: Label = $Label


func _ready() -> void:
	label.text = str(SaveData.save_data[1])


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()
	if event.is_action_pressed(&"ui_cancel"): _on_cancel_pressed()
	if event.is_action_pressed(&"ui_up"):
		SaveData.save_data[1] += 1
		label.text = str(SaveData.save_data[1])
	if event.is_action_pressed(&"ui_down"):
		SaveData.save_data[1] -= 1
		label.text = str(SaveData.save_data[1])


func _on_accept_pressed() -> void:
	System.save_manager.create_save("save_01")


func _on_cancel_pressed() -> void:
	System.save_manager.load_save("save_01")
	label.text = str(SaveData.save_data[1])
