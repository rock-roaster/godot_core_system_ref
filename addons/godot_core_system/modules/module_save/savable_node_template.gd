# meta-name: Savable Node
# meta-description: Savable Node can be register by Save Manager.
extends Node


var _data: Dictionary


func _ready() -> void:
	System.save_manager.register_savable_node(self)


func _save_data() -> Dictionary:
	return _data


func _load_data(data: Dictionary) -> void:
	_data = data


func get_data(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)


func set_data(key: String, value: Variant) -> void:
	_data.set(key, value)


func get_sub_data(section: String, key: String, default: Variant = null) -> Variant:
	if not _data.has(section): return null
	return _data[section].get(key, default)


func set_sub_data(section: String, key: String, value: Variant) -> void:
	if not _data.has(section): _data[section] = {}
	_data[section].set(key, value)
