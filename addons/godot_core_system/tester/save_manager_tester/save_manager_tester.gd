extends Node


@onready var label: Label = $Label


func _ready() -> void:
	var time_info: TimeInfo = TimeInfo.new()

	GameData.set_data("002", [
		Vector2(1.0, 5.0),
		label,
		time_info,
		StyleBox.new(),
	])

	GameData.set_data("003", {
		"1": label,
		"2": time_info,
		"3": StyleBox.new(),
	})
	label.text = str(GameData.get_data("001"))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()
	if event.is_action_pressed(&"ui_cancel"): _on_cancel_pressed()

	if event.is_action_pressed(&"ui_up"):
		GameData._data["001"] += 1
		label.text = str(GameData.get_data("001"))

	if event.is_action_pressed(&"ui_down"):
		GameData._data["001"] -= 1
		label.text = str(GameData.get_data("001"))


func _on_accept_pressed() -> void:
	System.save_manager.create_save("save_01")


func _on_cancel_pressed() -> void:
	await System.save_manager.load_save("save_01")
	label.text = str(GameData.get_data("001"))
