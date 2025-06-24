extends Node


var _data: Dictionary

var _save_manager: ModuleClass.ModuleSave:
	get: return System.save_manager

var _scene_manager: ModuleClass.ModuleScene:
	get: return System.scene_manager


func _ready() -> void:
	_save_manager.register_savable_node(self)
	_scene_manager.scene_saved.connect(_on_scene_saved)


func get_data(key: Variant, default: Variant = null) -> Variant:
	return _data.get(key, default)


func set_data(key: Variant, value: Variant) -> void:
	_data.set(key, value)


func get_sub_data(section: String, key: Variant, default: Variant = null) -> Variant:
	if not _data.has(section): return default
	return _data[section].get(key, default)


func set_sub_data(section: String, key: Variant, value: Variant) -> void:
	if not _data.has(section): _data[section] = {}
	_data[section].set(key, value)


func _on_scene_saved(path: String, data: Dictionary) -> void:
	if data.is_empty(): return
	set_sub_data("scene_data", path, data)


func _save_data() -> Dictionary:
	await get_tree().process_frame
	var last_scene_path: String = get_tree().current_scene.scene_file_path
	set_data("last_scene_path", last_scene_path)

	return _data


func _load_data(data: Dictionary) -> void:
	_data = data

	var last_scene_path: String = get_data("last_scene_path")
	var last_scene_data: Dictionary = get_sub_data("scene_data", last_scene_path, {})
	_scene_manager.clear_scene_stack()
	_scene_manager.change_scene_fade(last_scene_path, last_scene_data)
