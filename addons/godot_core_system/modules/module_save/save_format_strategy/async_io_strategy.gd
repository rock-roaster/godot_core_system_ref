extends "./save_format_strategy.gd"


var _io_manager: AsyncIOManager
var _encryption_key: String = ""


func _init() -> void:
	_io_manager = AsyncIOManager.new()


## 设置加密密钥
func set_encryption_key(key: String) -> void:
	_encryption_key = key


## 保存数据
func save(path: String, data: Dictionary) -> bool:
	var processed_data: Dictionary = _process_data_for_save(data)
	var task_id: String = _io_manager.write_file_async(path, processed_data, _encryption_key)
	var result: Array = await _io_manager.io_completed
	return result[1] if result[0] == task_id else false


## 加载数据
func load_save(path: String) -> Dictionary:
	var task_id: String = _io_manager.read_file_async(path, _encryption_key)
	var result: Array = await _io_manager.io_completed
	if result[0] == task_id and result[1]:
		return _process_data_for_load(result[2])
	return {}


## 加载元数据
func load_metadata(path: String) -> Dictionary:
	var data: Dictionary = await load_save(path)
	return data.get("metadata", {}) if data.has("metadata") else {}


## 处理数据保存
func _process_data_for_save(data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in data:
		result[key] = _process_data_value(data[key])
	return result


## 处理数据保存（单个判断）
func _process_data_value(value: Variant) -> Variant:
	match typeof(value):
		TYPE_INT:
			return {
				"__type": "int",
				"i": value,
			}
		TYPE_VECTOR2:
			return {
				"__type": "Vector2",
				"x": value.x,
				"y": value.y,
			}
		TYPE_VECTOR3:
			return {
				"__type": "Vector3",
				"x": value.x,
				"y": value.y,
				"z": value.z,
			}
		TYPE_COLOR:
			return {
				"__type": "Color",
				"r": value.r,
				"g": value.g,
				"b": value.b,
				"a": value.a,
			}
		TYPE_DICTIONARY:
			return _process_data_for_save(value)
		TYPE_ARRAY:
			return _process_array_for_save(value)
		TYPE_OBJECT:
			return _process_object_for_save(value)
	return value


## 处理数组保存
func _process_array_for_save(array: Array) -> Array:
	var result: Array = []
	for item in array: match typeof(item):
		TYPE_DICTIONARY:
			result.append(_process_data_for_save(item))
		TYPE_ARRAY:
			result.append(_process_array_for_save(item))
		TYPE_INT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR, TYPE_OBJECT:
			result.append(_process_data_for_save({"_": item})["_"])
		_:
			result.append(item)
	return result


## 处理对象保存
func _process_object_for_save(value: Object) -> Variant:
	if value is Node:
		return {
			"__type": "Node",
			"node_path": value.get_path(),
		}

	var object_dict: Dictionary = {"__type": "Object"}
	var prop_dict: Dictionary
	for prop in value.get_property_list():
		prop_dict.set(prop.name, value.get(prop.name))

	var script: Script = value.get_script()
	if script != null:
		var script_path: String = script.get_path()
		prop_dict.erase(script_path.get_file())
		object_dict["script"] = script_path
	else:
		object_dict["class"] = value.get_class()

	prop_dict.erase("script")
	object_dict["props"] = prop_dict
	return object_dict


## 处理数据加载
func _process_data_for_load(data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in data:
		var value: Variant = data[key]
		if value is Dictionary:
			result[key] = _process_dictionary_for_load(value)
		elif value is Array:
			result[key] = _process_array_for_load(value)
		else:
			result[key] = value
	return result


## 处理字典加载
func _process_dictionary_for_load(dict: Dictionary) -> Variant:
	if dict.has("__type"): match dict.__type:
		"int":
			return int(dict.i)
		"Vector2":
			return Vector2(dict.x, dict.y)
		"Vector3":
			return Vector3(dict.x, dict.y, dict.z)
		"Color":
			return Color(dict.r, dict.g, dict.b, dict.a)
		"Node":
			return NodePath(dict.node_path)
		"Object":
			return _process_object_for_load(dict)
	return _process_data_for_load(dict)


## 处理数组加载
func _process_array_for_load(array: Array) -> Array:
	var result: Array = []
	for item in array:
		if item is Dictionary:
			result.append(_process_data_for_load(item))
		elif item is Array:
			result.append(_process_array_for_load(item))
		else:
			result.append(item)
	return result


## 处理对象加载
func _process_object_for_load(value: Dictionary) -> Object:
	var object: Object
	if value.has("class"):
		object = ClassDB.instantiate(value.class)
	if value.has("script"):
		object = ResourceLoader.load(value.script, "Script").new()
	var prop_dict: Dictionary = value.props
	for prop_key in prop_dict:
		object.set(prop_key, prop_dict[prop_key])
	return object
