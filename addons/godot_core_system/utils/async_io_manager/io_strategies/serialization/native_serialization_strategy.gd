extends "./json_serialization_strategy.gd"


func serialize(data: Variant) -> PackedByteArray:
	var processed_data: Variant = _process_variant_for_save(data)
	var native_data: Variant = JSON.from_native(processed_data, true)
	return super(native_data)


func deserialize(bytes: PackedByteArray) -> Variant:
	var original_data: Variant = super(bytes)
	var native_data: Variant = JSON.to_native(original_data, true)
	return _process_variant_for_load(native_data)


## 处理字典方法
func _process_dictionary(value: Dictionary, method: Callable) -> Dictionary:
	var dictionary_data: Dictionary = {}
	for key in value:
		var p_key: Variant = method.call(key)
		var p_value: Variant = method.call(value[key])
		dictionary_data.set(p_key, p_value)
	return dictionary_data


## 处理数组方法
func _process_array(value: Array, method: Callable) -> Array:
	return value.map(method)


#region process for save

## 处理变量保存
func _process_variant_for_save(value: Variant) -> Variant:
	if value is Object:
		return _process_object_for_save(value)
	if value is Dictionary:
		return _process_dictionary_for_save(value)
	if value is Array:
		return _process_array_for_save(value)
	return value


## 处理对象保存
func _process_object_for_save(value: Object) -> Variant:
	if value is Node:
		return value.get_path()
	return value


## 处理字典保存
func _process_dictionary_for_save(value: Dictionary) -> Dictionary:
	var dictionary_data: Dictionary = _process_dictionary(value, _process_variant_for_save)
	if not value.is_typed(): return dictionary_data

	var value_dict: Dictionary = {}

	value_dict["type"] = TYPE_DICTIONARY
	value_dict["args"] = dictionary_data

	value_dict["key_type"] = value.get_typed_key_builtin()
	value_dict["key_class"] = value.get_typed_key_class_name()

	var typed_key_script: Script = value.get_typed_key_script() as Script
	value_dict["key_script"] = typed_key_script.get_path() if typed_key_script != null else ""

	value_dict["value_type"] = value.get_typed_value_builtin()
	value_dict["value_class"] = value.get_typed_value_class_name()

	var typed_value_script: Script = value.get_typed_value_script() as Script
	value_dict["value_script"] = typed_value_script.get_path() if typed_value_script != null else ""

	return value_dict


## 处理数组保存
func _process_array_for_save(value: Array) -> Variant:
	var array_data: Array = _process_array(value, _process_variant_for_save)
	if not value.is_typed(): return array_data

	var value_dict: Dictionary = {}
	value_dict["type"] = TYPE_ARRAY
	value_dict["args"] = array_data

	value_dict["value_type"] = value.get_typed_builtin()
	value_dict["class"] = value.get_typed_class_name()

	var array_typed_script: Script = value.get_typed_script() as Script
	value_dict["script"] = array_typed_script.get_path() if array_typed_script != null else ""
	return value_dict

#endregion


#region process for load

## 处理变量读取
func _process_variant_for_load(value: Variant) -> Variant:
	if value is Dictionary:
		return _process_dictionary_for_load(value)
	if value is Array:
		return _process_array_for_load(value)
	return value


## 处理字典读取
func _process_dictionary_for_load(value: Dictionary) -> Variant:
	if value.has("type"): match value.type:
		TYPE_DICTIONARY:
			return _process_typed_dictionary_for_load(value)
		TYPE_ARRAY:
			return _process_typed_array_for_load(value)
	return _process_dictionary(value, _process_variant_for_load)


## 处理数组读取
func _process_array_for_load(value: Array) -> Array:
	return _process_array(value, _process_variant_for_load)


## 处理类型字典读取
func _process_typed_dictionary_for_load(value: Dictionary) -> Dictionary:
	var dict_value: Dictionary = _process_dictionary_for_load(value.args)
	var dict_key_type: int = value.key_type
	var dict_key_class: StringName = ""
	var dict_key_script: Script = null
	var dict_value_type: int = value.value_type
	var dict_value_class: StringName = ""
	var dict_value_script: Script = null
	if dict_key_type == TYPE_OBJECT:
		var dict_script_path: String = value.key_script
		dict_key_class = value.key_class
		dict_key_script = ResourceLoader.load(dict_script_path, "Script")\
			if not dict_script_path.is_empty() else null
	if dict_value_type == TYPE_OBJECT:
		var dict_script_path: String = value.value_script
		dict_value_class = value.value_class
		dict_value_script = ResourceLoader.load(dict_script_path, "Script")\
			if not dict_script_path.is_empty() else null
	return Dictionary(dict_value, dict_key_type, dict_key_class, dict_key_script,
		dict_value_type, dict_value_class, dict_value_script)


## 处理类型数组读取
func _process_typed_array_for_load(value: Dictionary) -> Array:
	var array_value: Array = _process_array_for_load(value.args)
	var array_type: int = value.value_type
	var array_class: StringName = ""
	var array_script: Script = null
	if array_type == TYPE_OBJECT:
		var array_script_path: String = value.script
		array_class = value.class
		array_script = ResourceLoader.load(array_script_path, "Script")\
			if not array_script_path.is_empty() else null
	return Array(array_value, array_type, array_class, array_script)

#endregion
