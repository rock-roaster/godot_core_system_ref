extends RefCounted
class_name FileTools


static func get_exe_dir_path() -> String:
	return OS.get_executable_path().get_base_dir()


static func get_data_path() -> String:
	return get_exe_dir_path() + "/data"


static func get_user_dir_path() -> String:
	return ProjectSettings.globalize_path("user://")


static func copy_dir(from: String, to: String) -> void:
	if not from.ends_with("/"): from += "/"
	var dir_access: DirAccess = DirAccess.open(from)
	if dir_access == null: return
	dir_access.set_include_hidden(true)
	if not to.ends_with("/"): to += "/"
	dir_access.make_dir_recursive(to)
	for file_name in dir_access.get_files():
		if file_name.ends_with(".uid"): continue
		dir_access.copy(from + file_name, to + file_name)
	for dir_name in dir_access.get_directories():
		copy_dir(from + dir_name, to + dir_name)


static func remove_dir(path: String) -> void:
	if not path.ends_with("/"): path += "/"
	var dir_access: DirAccess = DirAccess.open(path)
	if dir_access == null: return
	dir_access.set_include_hidden(true)
	for file_name in dir_access.get_files():
		dir_access.remove(file_name)
	for dir_name in dir_access.get_directories():
		remove_dir(path + dir_name)
	dir_access.remove(".")


static func hide_dir(path: String) -> void:
	if not path.ends_with("/"): path += "/"
	if not DirAccess.dir_exists_absolute(path): return
	FileAccess.open(path + ".gdignore", FileAccess.WRITE).store_8(0)


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
