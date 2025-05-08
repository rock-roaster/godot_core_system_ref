extends "./async_io_strategy.gd"


func _init() -> void:
	_io_manager = AsyncIOManager.new(
		AsyncIOManager.JSONSerializationStrategy.new(),
		AsyncIOManager.GzipCompressionStrategy.new(),
		AsyncIOManager.NoEncryptionStrategy.new(),
	)


## 是否为有效存档
func is_valid_save_file(file_name: String) -> bool:
	return file_name.ends_with(".save")


## 获取存档ID
func get_save_id_from_file(file_name: String) -> String:
	return file_name.trim_suffix(".save")


## 获取存档路径
func get_save_path(directory: String, save_id: String) -> String:
	return directory.path_join("%s.save" % save_id)
