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
	var value_type: int = typeof(value)
	var value_dict: Dictionary = {"_type_": value_type}
	match value_type:
		TYPE_INT:
			value_dict["i"] = value
			return value_dict
		TYPE_VECTOR2, TYPE_VECTOR2I:
			value_dict["x"] = value.x
			value_dict["y"] = value.y
			return value_dict
		TYPE_RECT2, TYPE_RECT2I:
			value_dict["x"] = value.position.x
			value_dict["y"] = value.position.y
			value_dict["w"] = value.size.x
			value_dict["h"] = value.size.y
			return value_dict
		TYPE_VECTOR3, TYPE_VECTOR3I:
			value_dict["x"] = value.x
			value_dict["y"] = value.y
			value_dict["z"] = value.z
			return value_dict
		TYPE_TRANSFORM2D:
			value_dict["xx"] = value.x.x
			value_dict["xy"] = value.x.y
			value_dict["yx"] = value.y.x
			value_dict["yy"] = value.y.y
			value_dict["ox"] = value.origin.x
			value_dict["oy"] = value.origin.y
			return value_dict
		TYPE_VECTOR4, TYPE_VECTOR4I, TYPE_QUATERNION:
			value_dict["x"] = value.x
			value_dict["y"] = value.y
			value_dict["z"] = value.z
			value_dict["w"] = value.w
			return value_dict
		TYPE_PLANE:
			value_dict["a"] = value.x
			value_dict["b"] = value.y
			value_dict["c"] = value.z
			value_dict["d"] = value.d
			return value_dict
		TYPE_AABB:
			value_dict["px"] = value.position.x
			value_dict["py"] = value.position.y
			value_dict["pz"] = value.position.z
			value_dict["sx"] = value.size.x
			value_dict["sy"] = value.size.y
			value_dict["sz"] = value.size.z
			return value_dict
		TYPE_BASIS:
			value_dict["xx"] = value.x.x
			value_dict["xy"] = value.x.y
			value_dict["xz"] = value.x.z
			value_dict["yx"] = value.y.x
			value_dict["yy"] = value.y.y
			value_dict["yz"] = value.y.z
			value_dict["zx"] = value.z.x
			value_dict["zy"] = value.z.y
			value_dict["zz"] = value.z.z
			return value_dict
		TYPE_TRANSFORM3D:
			value_dict["xx"] = value.basis.x.x
			value_dict["xy"] = value.basis.x.y
			value_dict["xz"] = value.basis.x.z
			value_dict["yx"] = value.basis.y.x
			value_dict["yy"] = value.basis.y.y
			value_dict["yz"] = value.basis.y.z
			value_dict["zx"] = value.basis.z.x
			value_dict["zy"] = value.basis.z.y
			value_dict["zz"] = value.basis.z.z
			value_dict["ox"] = value.origin.x
			value_dict["oy"] = value.origin.y
			value_dict["oz"] = value.origin.z
			return value_dict
		TYPE_PROJECTION:
			value_dict["xx"] = value.x.x
			value_dict["xy"] = value.x.y
			value_dict["xz"] = value.x.z
			value_dict["xw"] = value.x.w
			value_dict["yx"] = value.y.x
			value_dict["yy"] = value.y.y
			value_dict["yz"] = value.y.z
			value_dict["yw"] = value.y.w
			value_dict["zx"] = value.z.x
			value_dict["zy"] = value.z.y
			value_dict["zz"] = value.z.z
			value_dict["zw"] = value.z.w
			value_dict["wx"] = value.w.x
			value_dict["wy"] = value.w.y
			value_dict["wz"] = value.w.z
			value_dict["ww"] = value.w.w
			return value_dict
		TYPE_COLOR:
			value_dict["r"] = value.r
			value_dict["g"] = value.g
			value_dict["b"] = value.b
			value_dict["a"] = value.a
			return value_dict
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
	var object_dict: Dictionary = {"_type_": TYPE_OBJECT}
	if value is Node:
		object_dict["_type_"] = TYPE_NODE_PATH
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
	if dict.has("_type_"): match int(dict._type_):
		TYPE_INT:
			return int(dict.i)
		TYPE_VECTOR2:
			return Vector2(dict.x, dict.y)
		TYPE_VECTOR2I:
			return Vector2i(dict.x, dict.y)
		TYPE_RECT2:
			return Rect2(dict.x, dict.y, dict.w, dict.h)
		TYPE_VECTOR2I:
			return Rect2i(dict.x, dict.y, dict.w, dict.h)
		TYPE_VECTOR3:
			return Vector3(dict.x, dict.y, dict.z)
		TYPE_VECTOR3I:
			return Vector3i(dict.x, dict.y, dict.z)
		TYPE_TRANSFORM2D:
			return Transform2D(
				Vector2(dict.xx, dict.xy),
				Vector2(dict.yx, dict.yy),
				Vector2(dict.ox, dict.oy),
			)
		TYPE_VECTOR4:
			return Vector4(dict.x, dict.y, dict.z, dict.w)
		TYPE_VECTOR4I:
			return Vector4i(dict.x, dict.y, dict.z, dict.w)
		TYPE_PLANE:
			return Plane(dict.a, dict.b, dict.c, dict.d)
		TYPE_QUATERNION:
			return Quaternion(dict.x, dict.y, dict.z, dict.w)
		TYPE_AABB:
			return AABB(
				Vector3(dict.px, dict.py, dict.pz),
				Vector3(dict.sx, dict.sy, dict.sz),
			)
		TYPE_BASIS:
			return Basis(
				Vector3(dict.xx, dict.xy, dict.xz),
				Vector3(dict.yx, dict.yy, dict.yz),
				Vector3(dict.zx, dict.zy, dict.zz),
			)
		TYPE_TRANSFORM3D:
			return Transform3D(
				Vector3(dict.xx, dict.xy, dict.xz),
				Vector3(dict.yx, dict.yy, dict.yz),
				Vector3(dict.zx, dict.zy, dict.zz),
				Vector3(dict.ox, dict.oy, dict.oz),
			)
		TYPE_PROJECTION:
			return Projection(
				Vector4(dict.xx, dict.xy, dict.xz, dict.xw),
				Vector4(dict.yx, dict.yy, dict.yz, dict.yw),
				Vector4(dict.zx, dict.zy, dict.zz, dict.zw),
				Vector4(dict.wx, dict.wy, dict.wz, dict.ww),
			)
		TYPE_COLOR:
			return Color(dict.r, dict.g, dict.b, dict.a)
		TYPE_NODE_PATH:
			return NodePath(dict.node_path)
		TYPE_OBJECT:
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
