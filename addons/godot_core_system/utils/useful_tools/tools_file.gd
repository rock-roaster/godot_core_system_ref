extends RefCounted
class_name FileTools


static func get_exe_dir_path() -> String:
	return OS.get_executable_path().get_base_dir()


static func get_user_dir_path() -> String:
	return ProjectSettings.globalize_path("user://") + "/data/"


static func get_progress(file_path: String) -> float:
	var load_progress: Array[float] = [0.0]
	ResourceLoader.load_threaded_get_status(file_path, load_progress)
	return load_progress[0] * 100


static func show_progress_percent(file_path: String) -> void:
	print("load_file: %s" % file_path)
	print("load_percent: %s %%\n" % get_progress(file_path))


static func save_json(path: String, data: Variant) -> void:
	var json_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var json_text: String = JSON.stringify(data, "\t", false)
	json_file.store_string(json_text)


static func load_json(path: String) -> Variant:
	var json_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var json_text: String = json_file.get_as_text()
	return JSON.parse_string(json_text)


static func preload_resource(path: String, type_hint: String = "") -> void:
	if not ResourceLoader.exists(path, type_hint): return
	ResourceLoader.load_threaded_request(path, type_hint)


static func get_preload_resource(path: String, type_hint: String = "") -> Resource:
	if not ResourceLoader.exists(path, type_hint): return null
	return ResourceLoader.load_threaded_get(path)


static func load_resource(path: String, type_hint: String = "") -> Resource:
	if not ResourceLoader.exists(path, type_hint): return null
	return ResourceLoader.load(path, type_hint)


static func get_dir_resource(dir_path: String, type_hint: String = "") -> Array[Resource]:
	var new_resource_array: Array[Resource] = []
	for file_name in ResourceLoader.list_directory(dir_path):
		var new_resource: Resource = load_resource(dir_path + file_name, type_hint)
		if new_resource == null: continue
		new_resource_array.append(new_resource.duplicate())
	return new_resource_array


static func get_safe_resource(res_data: Resource) -> Resource:
	var res_script: GDScript = res_data.get_script()

	var old_data: Resource = res_data.duplicate(true)
	var new_data: Resource = res_script.new()

	var old_property_list: Array[Dictionary] = old_data.get_property_list()
	for property in old_property_list:
		var property_name: String = property["name"]
		var old_property_data: Variant = old_data.get(property_name)
		var new_property_data: Variant = new_data.property_get_revert(property_name)

		if old_property_data == new_property_data: continue
		new_data.set(property_name, old_property_data)

	return new_data
