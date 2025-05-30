extends "./save_format_strategy.gd"

const GameStateData: = preload("../game_state_data.gd")

## 是否为有效的存档文件
func is_valid_save_file(file_name: String) -> bool:
	return file_name.ends_with(".tres")

## 获取存档名
func get_save_id_from_file(file_name: String) -> String:
	return file_name.trim_suffix(".tres")

## 获取存档路径
func get_save_path(directory: String, save_id: String) -> String:
	return directory.path_join("%s.tres" % save_id)

## 保存存档
func save(path: String, data: Dictionary) -> bool:
	var save_data: GameStateData = GameStateData.new()
	save_data.metadata = data.metadata
	# 设置节点状态
	save_data.nodes_state = data.nodes

	# 保存资源
	var error: Error = ResourceSaver.save(save_data, path)
	return error == OK

## 加载存档数据
func load_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var resource: Resource = ResourceLoader.load(path, "Resource")
	if resource == null:
		return {}

	var result: Dictionary = {
		"metadata": resource.metadata,
		"nodes": resource.nodes_state,
	}

	return result

## 加载元数据
func load_metadata(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var resource: Resource = ResourceLoader.load(path, "Resource")
	return resource.metadata if resource else {}
