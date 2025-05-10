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


## 将函数应用在字典的每一个值上，并返回新的字典
func _process_dictionary(dict: Dictionary, process_func: Callable) -> Dictionary:
	var result: Dictionary = {}
	for key in dict:
		var value: Variant = dict[key]
		result[key] = process_func.call(value)
	return result


#region process for save
## 处理数据保存
func _process_data_for_save(data: Dictionary) -> Dictionary:
	return _process_dictionary_for_save(data)


## 处理变量保存
func _process_variant_for_save(value: Variant) -> Variant:
	match typeof(value):
		TYPE_INT:
			return {
				"_type_": "int",
				"i": value,
			}
		TYPE_VECTOR2:
			return {
				"_type_": "Vector2",
				"x": value.x,
				"y": value.y,
			}
		TYPE_VECTOR2I:
			return {
				"_type_": "Vector2i",
				"x": value.x,
				"y": value.y,
			}
		TYPE_RECT2:
			return {
				"_type_": "Rect2",
				"x": value.position.x,
				"y": value.position.y,
				"w": value.size.x,
				"h": value.size.x,
			}
		TYPE_RECT2I:
			return {
				"_type_": "Rect2i",
				"x": value.position.x,
				"y": value.position.y,
				"w": value.size.x,
				"h": value.size.x,
			}
		TYPE_VECTOR3:
			return {
				"_type_": "Vector3",
				"x": value.x,
				"y": value.y,
				"z": value.z,
			}
		TYPE_VECTOR3I:
			return {
				"_type_": "Vector3i",
				"x": value.x,
				"y": value.y,
				"z": value.z,
			}
		TYPE_TRANSFORM2D:
			return {
				"_type_": "Transform2D",
				"x_x": value.x.x,
				"x_y": value.x.y,
				"y_x": value.y.x,
				"y_y": value.y.y,
				"o_x": value.origin.x,
				"o_y": value.origin.y,
			}
		TYPE_VECTOR4:
			return {
				"_type_": "Vector4",
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"w": value.w,
			}
		TYPE_VECTOR4I:
			return {
				"_type_": "Vector4i",
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"w": value.w,
			}
		TYPE_PLANE:
			return {
				"_type_": "Plane",
				"a": value.x,
				"b": value.y,
				"c": value.z,
				"d": value.d,
			}
		TYPE_QUATERNION:
			return {
				"_type_": "Quaternion",
				"x": value.x,
				"y": value.y,
				"z": value.z,
				"w": value.w,
			}
		TYPE_AABB:
			return {
				"_type_": "AABB",
				"p_x": value.position.x,
				"p_y": value.position.y,
				"p_z": value.position.z,
				"s_x": value.size.x,
				"s_y": value.size.y,
				"s_z": value.size.z,
			}
		TYPE_BASIS:
			return {
				"_type_": "Basis",
				"x_x": value.x.x,
				"x_y": value.x.y,
				"x_z": value.x.z,
				"y_x": value.y.x,
				"y_y": value.y.y,
				"y_z": value.y.z,
				"z_x": value.z.x,
				"z_y": value.z.y,
				"z_z": value.z.z,
			}
		TYPE_TRANSFORM3D:
			return {
				"_type_": "Transform3D",
				"x_x": value.basis.x.x,
				"x_y": value.basis.x.y,
				"x_z": value.basis.x.z,
				"y_x": value.basis.y.x,
				"y_y": value.basis.y.y,
				"y_z": value.basis.y.z,
				"z_x": value.basis.z.x,
				"z_y": value.basis.z.y,
				"z_z": value.basis.z.z,
				"o_x": value.origin.x,
				"o_y": value.origin.y,
				"o_z": value.origin.z,
			}
		TYPE_PROJECTION:
			return {
				"_type_": "Projection",
				"x_x": value.x.x,
				"x_y": value.x.y,
				"x_z": value.x.z,
				"x_w": value.x.w,
				"y_x": value.y.x,
				"y_y": value.y.y,
				"y_z": value.y.z,
				"y_w": value.y.w,
				"z_x": value.z.x,
				"z_y": value.z.y,
				"z_z": value.z.z,
				"z_w": value.z.w,
				"w_x": value.w.x,
				"w_y": value.w.y,
				"w_z": value.w.z,
				"w_w": value.w.w,
			}
		TYPE_COLOR:
			return {
				"_type_": "Color",
				"r": value.r,
				"g": value.g,
				"b": value.b,
				"a": value.a,
			}
		TYPE_OBJECT:
			return _process_object_for_save(value)
		TYPE_DICTIONARY:
			return _process_dictionary_for_save(value)
		TYPE_ARRAY:
			return _process_array_for_save(value)
	return value


## 处理字典保存
func _process_dictionary_for_save(dict: Dictionary) -> Dictionary:
	return _process_dictionary(dict, _process_variant_for_save)


## 处理数组保存
func _process_array_for_save(array: Array) -> Array:
	return array.map(_process_variant_for_save)


## 处理对象保存
func _process_object_for_save(value: Object) -> Dictionary:
	var object_dict: Dictionary = {"_type_": "Object"}
	if value is Node:
		object_dict["_type_"] = "NodePath"
		object_dict["node_path"] = value.get_path()
		return object_dict

	var prop_dict: Dictionary
	for prop in value.get_property_list():
		var prop_name: String = prop["name"]
		var prop_value: Variant = value.get(prop_name)
		prop_dict.set(prop_name, _process_variant_for_save(prop_value))

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
#endregion


#region process for load
## 处理数据加载
func _process_data_for_load(data: Dictionary) -> Dictionary:
	return _process_dictionary(data, _process_variant_for_load)


## 处理变量加载
func _process_variant_for_load(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			return _process_dictionary_for_load(value)
		TYPE_ARRAY:
			return _process_array_for_load(value)
	return value


## 处理字典加载
func _process_dictionary_for_load(dict: Dictionary) -> Variant:
	if dict.has("_type_"): match dict._type_:
		"int":
			return int(dict.i)
		"Vector2":
			return Vector2(dict.x, dict.y)
		"Vector2i":
			return Vector2i(dict.x, dict.y)
		"Rect2":
			return Rect2(dict.x, dict.y, dict.w, dict.h)
		"Rect2i":
			return Rect2i(dict.x, dict.y, dict.w, dict.h)
		"Vector3":
			return Vector3(dict.x, dict.y, dict.z)
		"Vector3i":
			return Vector3i(dict.x, dict.y, dict.z)
		"Transform2D":
			return Transform2D(
				Vector2(dict.x_x, dict.x_y),
				Vector2(dict.y_x, dict.y_y),
				Vector2(dict.o_x, dict.o_y),
			)
		"Vector4":
			return Vector4(dict.x, dict.y, dict.z, dict.w)
		"Vector4i":
			return Vector4i(dict.x, dict.y, dict.z, dict.w)
		"Plane":
			return Plane(dict.a, dict.b, dict.c, dict.d)
		"Quaternion":
			return Quaternion(dict.x, dict.y, dict.z, dict.w)
		"AABB":
			return AABB(
				Vector3(dict.p_x, dict.p_y, dict.p_z),
				Vector3(dict.s_x, dict.s_y, dict.s_z),
			)
		"Basis":
			return Basis(
				Vector3(dict.x_x, dict.x_y, dict.x_z),
				Vector3(dict.y_x, dict.y_y, dict.y_z),
				Vector3(dict.z_x, dict.z_y, dict.z_z),
			)
		"Transform3D":
			return Transform3D(
				Vector3(dict.x_x, dict.x_y, dict.x_z),
				Vector3(dict.y_x, dict.y_y, dict.y_z),
				Vector3(dict.z_x, dict.z_y, dict.z_z),
				Vector3(dict.o_x, dict.o_y, dict.o_z),
			)
		"Projection":
			return Projection(
				Vector4(dict.x_x, dict.x_y, dict.x_z, dict.x_w),
				Vector4(dict.y_x, dict.y_y, dict.y_z, dict.y_w),
				Vector4(dict.z_x, dict.z_y, dict.z_z, dict.z_w),
				Vector4(dict.w_x, dict.w_y, dict.w_z, dict.w_w),
			)
		"Color":
			return Color(dict.r, dict.g, dict.b, dict.a)
		"NodePath":
			return NodePath(dict.node_path)
		"Object":
			return _process_object_for_load(dict)
	return _process_dictionary(dict, _process_variant_for_load)


## 处理数组加载
func _process_array_for_load(array: Array) -> Array:
	return array.map(_process_variant_for_load)


## 处理对象加载
func _process_object_for_load(value: Dictionary) -> Object:
	var object: Object
	if value.has("class"):
		object = ClassDB.instantiate(value.class)
	if value.has("script"):
		object = ResourceLoader.load(value.script, "Script").new()
	var prop_dict: Dictionary = value.props
	for prop_key in prop_dict:
		var prop_value: Variant = _process_variant_for_load(prop_dict[prop_key])
		object.set(prop_key, prop_value)
	return object
#endregion
