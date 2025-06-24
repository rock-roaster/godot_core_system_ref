extends "./json_serialization_strategy.gd"


func serialize(data: Variant) -> PackedByteArray:
	var processed_data: Variant = _process_variant_for_save(data)
	var native_data: Variant = JSON.from_native(processed_data, true)
	return super(native_data)


func deserialize(bytes: PackedByteArray) -> Variant:
	var original_data: Variant = super(bytes)
	var native_data: Variant = JSON.to_native(original_data, true)
	return native_data


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


func _process_dictionary_for_save(value: Dictionary) -> Dictionary:
	var result: Dictionary
	for key in value:
		var p_key: Variant = _process_variant_for_save(key)
		var p_value: Variant = _process_variant_for_save(value[key])
		result.set(p_key, p_value)
	return result


func _process_array_for_save(value: Array) -> Array:
	return value.map(_process_variant_for_save)

#endregion
