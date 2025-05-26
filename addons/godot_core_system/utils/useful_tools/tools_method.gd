extends RefCounted
class_name MethodTools


static func get_callable_pack(callable: Callable) -> Dictionary:
	if !callable.is_valid(): return {}
	return {
		"object": callable.get_object(),
		"method": callable.get_method(),
		"arguments": callable.get_bound_arguments(),
	}


static func call_callable_pack(pack: Dictionary, bind: Array = []) -> bool:
	if pack.is_empty(): return false

	var callable_object: Object = pack.object
	if !is_instance_valid(callable_object):
		push_error("invalid object: ", callable_object)
		return false

	var callable_method: StringName = pack.method
	if !callable_object.has_method(callable_method):
		push_error("unfound method: ", callable_method)
		return false

	var callable_arguments: Array = pack.arguments
	callable_arguments.append_array(bind)

	await callable_object.callv(callable_method, callable_arguments)
	return true
