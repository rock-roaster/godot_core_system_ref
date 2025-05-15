extends "res://addons/godot_core_system/modules/module_base.gd"


var _thread_dictionary: Dictionary[StringName, SingleThread]


func add_task(
	name: StringName,
	function: Callable,
	callback: Callable = func(_result: Variant): pass,
	auto_advance: bool = false,
	call_deferred: bool = true,
	) -> void:

	if not _thread_dictionary.has(name):
		create_thread(name)

	var target_thread: SingleThread = _thread_dictionary.get(name) as SingleThread
	target_thread.add_task(function, callback, auto_advance, call_deferred)


func next_step(name: StringName) -> void:
	if not _thread_dictionary.has(name):
		print("thread not found: ", name)
		return

	var target_thread: SingleThread = _thread_dictionary.get(name) as SingleThread
	target_thread.next_step()


func create_thread(name: StringName) -> SingleThread:
	var new_thread: SingleThread = SingleThread.new()
	_thread_dictionary.set(name, new_thread)
	print("thread created: ", name)
	return new_thread


func clear_threads() -> void:
	var thread_names: Array[StringName] = _thread_dictionary.keys()
	_thread_dictionary.clear()
	for thread_name in thread_names:
		print("thread unloaded: ", thread_name)


func unload_thread(name: StringName) -> void:
	if _thread_dictionary.has(name):
		_thread_dictionary.erase(name)
		print("thread unloaded: ", name)
	else:
		print("thread already unloaded: ", name)
