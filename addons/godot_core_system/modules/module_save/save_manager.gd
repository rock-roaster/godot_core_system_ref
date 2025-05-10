extends "res://addons/godot_core_system/modules/module_base.gd"

## 存档管理器，负责存档的创建、加载、删除等操作

# 引用类型
const GameStateData = preload("./game_state_data.gd")
const SaveFormatStrategy = preload("./save_format_strategy/save_format_strategy.gd")
const ResourceSaveStrategy = preload("./save_format_strategy/resource_save_strategy.gd")
const BinarySaveStrategy = preload("./save_format_strategy/binary_save_strategy.gd")
const JSONSaveStrategy = preload("./save_format_strategy/json_save_strategy.gd")

# 信号
signal save_created(save_id: String, metadata: Dictionary)		# 存档创建
signal save_loaded(save_id: String, metadata: Dictionary)		# 存档加载
signal save_deleted(save_id: String)							# 存档删除
signal auto_save_created(save_id: String)						# 自动存档创建

# 配置属性
var save_directory: String:
	get: return System.get_setting_value("module_save/save_directory", "user://saves")
	set(value): System.logger.error("read-only")

var save_group: String:
	get: return System.get_setting_value("module_save/save_group", "savable")
	set(value): System.logger.error("read-only")

var default_format: String:
	get: return System.get_setting_value("module_save/defaults/serialization_format", "resource")
	set(value): System.logger.error("read-only")

var auto_save_enabled: bool:
	get: return System.get_setting_value("module_save/auto_save/enabled", true)
	set(value): System.logger.error("read-only")

var auto_save_interval: float:
	get: return System.get_setting_value("module_save/auto_save/interval_seconds", 300.0)
	set(value): System.logger.error("read-only")

var auto_save_prefix: String:
	get: return System.get_setting_value("module_save/auto_save/name_prefix", "auto_save_")
	set(value): System.logger.error("read-only")

var max_auto_saves: int:
	get: return System.get_setting_value("module_save/auto_save/max_saves", 5)
	set(value): System.logger.error("read-only")

# 私有变量
var _current_save_id: String = ""
var _auto_save_timer: float = 0
var _encryption_key: String = ""
var _save_strategy: SaveFormatStrategy
var _pending_node_states: Dictionary = {}

var _strategies := {
	"resource": ResourceSaveStrategy.new(),
	"binary": BinarySaveStrategy.new(),
	"json": JSONSaveStrategy.new(),
}
var _logger: ModuleClass.ModuleLog = System.logger


func _init() -> void:
	# 确保存档目录存在
	_ensure_save_directory_exists()


func _process(delta: float) -> void:
	if auto_save_enabled and not _current_save_id.is_empty():
		_auto_save_timer += delta
		if _auto_save_timer >= auto_save_interval:
			_auto_save_timer = 0
			create_auto_save()


#region 公共API
# 注册存档节点
func register_savable_node(node: Node) -> void:
	if not node.is_in_group(save_group):
		node.add_to_group(save_group)
		System.logger.info("注册存档节点: %s" % node.get_path())

	var node_path: String = node.get_path()
	# 检查是否有待加载的缓存状态
	if _pending_node_states.has(node_path):
		_logger.debug("发现节点 %s 的缓存状态，正在应用..." % node_path)
		var cached_data = _pending_node_states[node_path]
		if node.has_method("load_data"):
			#await get_tree().process_frame
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

	# 收集数据
	var save_data: Dictionary = {
		"metadata": {
			"save_id": actual_id,
			"timestamp": Time.get_unix_time_from_system(),
			"save_date": Time.get_datetime_string_from_system(false, true),
			"game_version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
			"playtime": 0.0,
		},
		"nodes": _collect_node_states(),
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
	var save_path: String = _get_save_path(save_id)
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
		System.logger.error("Failed to create auto save: %s" % auto_save_id)
		return ""

	# 清理旧的自动存档
	var cleanup_success: bool = await _clean_old_auto_saves()
	if not cleanup_success:
		System.logger.warning("Failed to clean old auto saves")

	# 发送信号
	auto_save_created.emit(auto_save_id)
	return auto_save_id


# 获取所有存档列表
func get_save_list() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []

	var files: Array = _save_strategy.list_files(save_directory)
	for file in files:
		var save_id: String = _get_save_id_from_file(file)
		var save_path: String = _get_save_path(save_id)

		var metadata: Dictionary = await _save_strategy.load_metadata(save_path)
		if not metadata.is_empty():
			saves.append({
				"save_id": save_id,
				"metadata": metadata
			})

	# 按时间戳排序
	saves.sort_custom(func(a, b):
		return a.metadata.timestamp > b.metadata.timestamp)

	return saves


# 注册自定义存档格式策略
func register_save_format_strategy(format: StringName, strategy: SaveFormatStrategy) -> void:
	_strategies[format] = strategy
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
	# 从配置中获取密钥
	var key: String = System.config_manager.get_value("save_system", "encryption_key", "")

	# 如果配置中没有密钥，生成一个默认的
	if key.is_empty():
		key = _generate_default_key()
		System.config_manager.set_value("save_system", "encryption_key", key)
		System.config_manager.save_config()

	return key


## 生成默认密钥
func _generate_default_key() -> String:
	var key: String = ""
	for i in range(32):
		key += str(randi() % 10)
	return key
	# return "123456"


# 检查文件是否为有效的存档文件
func _is_valid_save_file(file_name: String) -> bool:
	return _save_strategy.is_valid_save_file(file_name)


# 从文件名获取存档ID
func _get_save_id_from_file(file_name: String) -> String:
	return _save_strategy.get_save_id_from_file(file_name)


# 确保存档目录存在
func _ensure_save_directory_exists() -> void:
	var save_dir: String = System.get_setting_value("module_save/save_directory")
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)


# 获取存档路径
func _get_save_path(save_id: String) -> String:
	return _save_strategy.get_save_path(
		System.get_setting_value("module_save/save_directory"), save_id)


# 清理旧的自动存档
func _clean_old_auto_saves() -> bool:
	var saves: Array[Dictionary] = await get_save_list()
	var auto_saves: Array[Dictionary] = saves.filter(
		func(save: Dictionary):
			var save_id: String = save.get("save_id")
			return save_id.begins_with(auto_save_prefix)
	)

	var success: bool = true
	if auto_saves.size() > max_auto_saves:
		for i in range(max_auto_saves, auto_saves.size()):
			var result: bool = delete_save(auto_saves[i].id)
			if not result: success = false
	return success


# 生成时间戳
func _get_timestamp() -> String:
	return str(Time.get_unix_time_from_system())


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
			var savable_data: Dictionary = savable.call("_save_data")
			node_data["node_path"] = savable.get_path()
			node_data.merge(savable_data)
			nodes.append(node_data)
		else:
			_logger.warning("缺少 _save_data 方法！%s" % str(savable))
	return nodes


# 应用Node状态
func _apply_node_states(nodes: Array) -> void:
	for node_data: Dictionary in nodes:
		var node_path: String = node_data.get("node_path", "")
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
