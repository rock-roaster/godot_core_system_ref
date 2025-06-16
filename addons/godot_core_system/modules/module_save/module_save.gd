extends "../module_base.gd"

## 存档管理器，负责存档的创建、加载、删除等操作

# 引用类型
const SaveFormatStrategy = preload("./save_format_strategy/save_format_strategy.gd")
const JSONSaveStrategy = preload("./save_format_strategy/json_save_strategy.gd")
const BinarySaveStrategy = preload("./save_format_strategy/binary_save_strategy.gd")
const ResourceSaveStrategy = preload("./save_format_strategy/resource_save_strategy.gd")

# 信号
signal ready_to_save
signal save_created(save_id: String, metadata: Dictionary)		# 存档创建
signal save_loaded(save_id: String, metadata: Dictionary)		# 存档加载
signal save_deleted(save_id: String)							# 存档删除
signal auto_save_created(save_id: String)						# 自动存档创建

# 配置属性
var save_directory: String:
	get: return _system.get_setting_value("module_save/save_directory")

var save_group: String:
	get: return _system.get_setting_value("module_save/save_group")

var default_format: String:
	get: return _system.get_setting_value("module_save/serialization_format")

var auto_save_enabled: bool:
	get: return _system.get_setting_value("module_save/auto_save/enabled")

var max_auto_saves: int:
	get: return _system.get_setting_value("module_save/auto_save/max_saves")

var auto_save_interval: float:
	get: return _system.get_setting_value("module_save/auto_save/interval_seconds")

var auto_save_prefix: String:
	get: return _system.get_setting_value("module_save/auto_save/name_prefix")

# 私有变量
var _current_save_id: String = ""
var _encryption_key: String = ""

var _play_time: float = 0.0
var _auto_save_timer: float = 0.0

var _save_strategy: SaveFormatStrategy
var _pending_node_states: Dictionary[NodePath, Dictionary] = {}

var _strategies: Dictionary[StringName, SaveFormatStrategy] = {
	"json": JSONSaveStrategy.new(),
	"binary": BinarySaveStrategy.new(),
	"resource": ResourceSaveStrategy.new(),
}

var _logger: ModuleClass.ModuleLog:
	get: return _system.logger

var _config_manager: ModuleClass.ModuleConfig:
	get: return _system.config_manager


func _init() -> void:
	# 确保存档目录存在
	_ensure_save_directory_exists()
	_set_save_format(default_format)


func _process(delta: float) -> void:
	if auto_save_enabled and not _current_save_id.is_empty():
		_auto_save_timer += delta
		if _auto_save_timer >= auto_save_interval:
			_auto_save_timer = 0.0
			create_auto_save()


#region 公共API
# 注册存档节点
func register_savable_node(node: Node) -> void:
	var node_path: NodePath = node.get_path()

	if not node.is_in_group(save_group):
		node.add_to_group(save_group)
		_logger.info("注册存档节点: %s" % node_path)

	# 检查是否有待加载的缓存状态
	if _pending_node_states.has(node_path):
		_logger.debug("发现节点 %s 的缓存状态，正在应用..." % node_path)
		var cached_data: Dictionary = _pending_node_states[node_path]
		if node.has_method("load_data"):
			node.load_data(cached_data)
			# 加载后从缓存移除
			_pending_node_states.erase(node_path)
		else:
			_logger.warning("节点 %s 缺少 load_data 方法，无法应用缓存状态！" % node_path)


# 设置存档格式
func set_save_format(format: StringName) -> void:
	_set_save_format(format)


func update_save() -> void:
	if _current_save_id != "":
		create_save(_current_save_id)


# 创建存档
func create_save(save_id: String = "") -> bool:
	var actual_id: String = _generate_save_id() if save_id.is_empty() else save_id
	ready_to_save.emit()

	# 收集数据
	var save_data: Dictionary = {
		"metadata": {
			"save_id": actual_id,
			"unix_time": Time.get_unix_time_from_system(),
			"save_date": Time.get_datetime_string_from_system(false, true),
			"play_time": _play_time,
			"game_version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
		},
		"nodes": await _collect_node_states(),
	}

	# 存储数据
	_set_save_format(default_format)
	var save_path: String = _get_save_path(actual_id)
	var success: bool = await _save_strategy.save(save_path, save_data)
	if success:
		_current_save_id = actual_id
		save_created.emit(actual_id, save_data.metadata)
		return true
	return false


# 加载存档
func load_save(save_id: String) -> bool:
	if save_id.is_empty():
		return false

	_set_save_format(default_format)
	var save_path: String = _get_save_path(save_id)

	var result: Dictionary = await _save_strategy.load_save(save_path)
	if not result.is_empty():
		_current_save_id = save_id
		if result.has("nodes"):
			_apply_node_states(result.nodes)
		save_loaded.emit(save_id, result.metadata)
		return true
	return false


# 删除存档
func delete_save(save_id: String) -> bool:
	var save_dict: Dictionary = await get_save(save_id)
	if save_dict.is_empty():
		_logger.error("要删除的存档不存在：%s" % save_id)
		return false

	var save_path: String = save_dict.save_path
	var success: bool = _save_strategy.delete_file(save_path)

	if success:
		if _current_save_id == save_id:
			_current_save_id = ""
		save_deleted.emit(save_id)
		return true
	_logger.error("删除存档失败：%s" % save_path)
	return false


# 创建自动存档
func create_auto_save() -> String:
	var auto_save_id: String = _get_auto_save_id()

	# 创建新存档
	var success: bool = await create_save(auto_save_id)
	if not success:
		_logger.error("Failed to create auto save: %s" % auto_save_id)
		return ""

	# 清理旧的自动存档
	var cleanup_success: bool = await _clean_old_auto_saves()
	if not cleanup_success:
		_logger.warning("Failed to clean old auto saves")

	# 发送信号
	auto_save_created.emit(auto_save_id)
	return auto_save_id


# 注册自定义存档格式策略
func register_save_format_strategy(format: StringName, strategy: SaveFormatStrategy) -> void:
	_strategies[format] = strategy
#endregion


#region 获得存档信息
# 获取所有存档列表
func get_save_list() -> Array[Dictionary]:
	var save_list: Array[Dictionary] = []

	var files: Array = _save_strategy.list_files(save_directory)
	for file in files:
		var save_path: String = save_directory.path_join(file)
		var metadata: Dictionary = await _save_strategy.load_metadata(save_path)
		if not metadata.is_empty():
			var save_data: Dictionary = {
				"metadata": metadata,
				"save_id": metadata.save_id,
				"save_path": save_path,
			}
			save_list.append(save_data)

	# 按时间戳排序
	save_list.sort_custom(func(a: Dictionary, b: Dictionary):
		return a.metadata.unix_time > b.metadata.unix_time)

	return save_list


func get_save(save_id: String) -> Dictionary:
	var save_list: Array[Dictionary] = await get_save_list()
	for save in save_list:
		if save.save_id == save_id: return save
	return {}


func save_exist(save_id: String) -> bool:
	var save_dict: Dictionary = await get_save(save_id)
	return !save_dict.is_empty()


func get_latest_auto_save() -> Dictionary:
	var save_list: Array[Dictionary] = await get_save_list_auto()
	if save_list.is_empty(): return {}
	return save_list[0]


func get_save_list_normal() -> Array[Dictionary]:
	var save_list: Array[Dictionary] = await get_save_list()
	save_list = save_list.filter(func(value: Dictionary):
		var save_id: String = value.save_id
		return !save_id.begins_with(auto_save_prefix))
	return save_list


func get_save_list_auto() -> Array[Dictionary]:
	var save_list: Array[Dictionary] = await get_save_list()
	save_list = save_list.filter(func(value: Dictionary):
		var save_id: String = value.save_id
		return save_id.begins_with(auto_save_prefix))
	return save_list
#endregion


#region 辅助方法
func _get_auto_save_id() -> String:
	return auto_save_prefix + _get_timestamp()


# 设置当前存档格式
func _set_save_format(format: StringName) -> void:
	_save_strategy = _strategies.get(format, "resource")
	if _save_strategy.has_method("set_encryption_key"):
		var encryption_key: String = _get_encryption_key()
		_save_strategy.set_encryption_key(encryption_key)


## 获取加密密钥
func _get_encryption_key() -> String:
	var config_file: ConfigFile = ConfigFile.new()
	var config_path: String = save_directory + "/save_encryption_key.cfg"
	var load_result: Error = config_file.load(config_path)
	if load_result != OK:
		var new_key: String = _generate_random_key()
		config_file.set_value("save_system", "encryption_key", new_key)
		config_file.save(config_path)
	return config_file.get_value("save_system", "encryption_key")


## 生成随机密钥
func _generate_random_key(digits: int = 32) -> String:
	var new_key: String = ""
	for i in range(digits):
		new_key += str(randi() % 10)
	return new_key


# 检查文件是否为有效的存档文件
func _is_valid_save_file(file_name: String) -> bool:
	return _save_strategy.is_valid_save_file(file_name)


# 从文件名获取存档ID
func _get_save_id_from_file(file_name: String) -> String:
	return _save_strategy.get_save_id_from_file(file_name)


# 确保存档目录存在
func _ensure_save_directory_exists() -> void:
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_recursive_absolute(save_directory)


# 获取存档路径
func _get_save_path(save_id: String) -> String:
	return _save_strategy.get_save_path(save_directory, save_id)


# 清理旧的自动存档
func _clean_old_auto_saves() -> bool:
	var auto_saves: Array[Dictionary] = await get_save_list_auto()
	var success: bool = true
	if auto_saves.size() > max_auto_saves:
		for i in range(max_auto_saves, auto_saves.size()):
			var result: bool = await delete_save(auto_saves[i].save_id)
			if not result: success = false
	return success


# 生成时间戳
func _get_timestamp() -> String:
	return str(int(Time.get_unix_time_from_system()))


# 生成存档ID
func _generate_save_id() -> String:
	return "save_" + _get_timestamp()


# 收集Node状态
func _collect_node_states() -> Array[Dictionary]:
	var nodes: Array[Dictionary] = []
	var savables: Array[Node] = _current_tree.get_nodes_in_group(save_group)
	for savable in savables:
		if savable.has_method("_save_data"):
			var node_data: Dictionary = {}
			var savable_data: Dictionary = await savable.call("_save_data")
			node_data["node_path"] = savable.get_path()
			node_data.merge(savable_data)
			nodes.append(node_data)
		else:
			_logger.warning("缺少 _save_data 方法！%s" % str(savable))
	return nodes


# 应用Node状态
func _apply_node_states(nodes: Array) -> void:
	for node_data: Dictionary in nodes:
		var node_path: NodePath = node_data.get("node_path", "")
		if node_path.is_empty():
			_logger.error("节点路径为空！%s" % str(node_data))
			continue
		var node: Node = _current_root.get_node_or_null(node_path)
		if node != null:
			if node.has_method("_load_data"):
				node_data.erase("node_path")
				node.call("_load_data", node_data)
			else:
				_logger.warning("缺少 _load_data 方法！%s" % str(node))
		else:
			# 节点不存在，缓存数据
			_logger.debug("节点 %s 尚未加载，缓存其状态数据。" % node_path)
			_pending_node_states[node_path] = node_data
#endregion
