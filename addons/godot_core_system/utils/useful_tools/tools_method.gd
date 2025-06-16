extends RefCounted
class_name MethodTools


static func get_callable_pack(callable: Callable, arguments: Array = []) -> Dictionary:
	if !callable.is_valid(): return {}

	var bound_arguments: Array = callable.get_bound_arguments()
	arguments.append_array(bound_arguments)

	return {
		"object": callable.get_object(),
		"method": callable.get_method(),
		"arguments": arguments,
	}


static func call_callable_pack(pack: Dictionary, arguments: Array = []) -> bool:
	if pack.is_empty(): return false

	var callable_object: Object = pack.object
	if !is_instance_valid(callable_object):
		push_error("invalid object: ", callable_object)
		return false

	var callable_method: StringName = pack.method
	if !callable_object.has_method(callable_method):
		push_error("unfound method: ", callable_method)
		return false

	var bound_arguments: Array = pack.arguments
	arguments.append_array(bound_arguments)

	await callable_object.callv(callable_method, arguments)
	return true
