extends RefCounted
class_name MethodTools


static func get_callable(object: Variant, method: StringName) -> Callable:
	if not is_instance_valid(object):
		print("object not valid: ", object)
		if OS.is_debug_build(): push_error("object not valid: ", object)
		return Callable()
	object = object as Object
	if not object.has_method(method):
		print("method not exisit: ", method)
		if OS.is_debug_build(): push_error("method not exisit: ", method)
		return Callable()
	return Callable(object, method)


static func safe_method_call(object: Variant, method: StringName, args: Array = []) -> void:
	var safe_callable: Callable = get_callable(object, method)
	if safe_callable.is_null(): return
	var argument_count: int = safe_callable.get_argument_count()
	if args.size() != argument_count:
		args.resize(argument_count)
		print("wrong amount of argument imported: ", method)
		if OS.is_debug_build(): push_error("wrong amount of argument imported: ", method)
	safe_callable.callv(args)
