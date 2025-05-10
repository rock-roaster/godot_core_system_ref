# meta-name: Savable Node
# meta-description: Savable Node register by Save Manager.
extends Node


var _data: Dictionary


func _ready() -> void:
	System.save_manager.register_saveable_node(self)


func _save_data() -> Dictionary:
	return _data


func _load_data(data: Dictionary) -> void:
	_data = data


func get_data(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)


func set_data(key: String, value: Variant) -> void:
	_data.set(key, value)
