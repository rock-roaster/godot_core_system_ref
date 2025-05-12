extends Node


@onready var label: Label = $Label

@onready var character: Character = $Character


func _ready() -> void:
	var char_data: CharacterData = CharacterData.get_character_data(
		"res://addons/dialogue_manager/tester/sample_character/小恶魔/小恶魔.tres").duplicate(true)
	GameData.set_data("char_01", char_data)
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
	character.set_character_data(GameData.get_data("char_01"))
