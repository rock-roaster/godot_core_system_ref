extends Node


var random_picker: RandomPicker = RandomPicker.new()


func _ready() -> void:
	random_picker.add_item("Hello World! 01", 1.0)
	random_picker.add_item("Hello World! 02", 10.0)
	random_picker.add_item("Hello World! 03", 100.0)
	random_picker.add_item("Hello World! 04", 1000.0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		print(random_picker.get_random_item(true))
