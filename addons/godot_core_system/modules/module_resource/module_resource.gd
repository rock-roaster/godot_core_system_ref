extends "res://addons/godot_core_system/modules/module_base.gd"

## 资源管理器
## 负责管理资源的加载，缓存和对象池

## 资源加载信号
signal resource_loaded(path: String, resource: Resource)
## 资源卸载信号
signal resource_unloaded(path: String)

## 资源缓存
var _resource_cache: Dictionary[String, Resource] = {}
## 对象池
var _instance_pools: Dictionary[StringName, Array] = {}

## 当前懒加载时间
var _lazy_load_time: float = 0.0
## 懒加载时间间隔
var _lazy_load_interval: float = 0.5

## 待加载地址列表
var _pending_path_list: Array[Dictionary]
## 加载中地址列表
var _loading_path_list: Array[String]

## 加载中资源数量
var _loading_count: int = 0
## 最大加载中资源数量
var _max_loading_count: int = 100

var _logger: ModuleClass.ModuleLog:
	get: return System.logger


## 处理懒加载
func _process(delta: float) -> void:
	_check_pending()
	_lazy_load(delta)


## 获得文件夹中的所有资源路径
func get_file_list(dir_path: String) -> Array[String]:
	var file_list: Array[String] = []
	if not dir_path.ends_with("/"): dir_path += "/"
	for file_name in ResourceLoader.list_directory(dir_path):
		file_list.append(dir_path + file_name)
	return file_list


## 加载资源；
## [param path] 为资源路径；
## 返回加载的资源
func load_resource(
	path: String,
	type_hint: String = "",
	cache_mode: ResourceLoader.CacheMode = 1,
	) -> Resource:

	# 如果资源已经加载过了
	if _resource_cache.has(path) and _resource_cache[path] != null:
		return _resource_cache[path]

	if not ResourceLoader.exists(path, type_hint):
		_logger.error("[ResourceManager] resource path not existed: " + path)
		return null

	var resource: Resource = ResourceLoader.load(path, type_hint, cache_mode)
	_resource_cache[path] = resource

	if resource != null:
		resource_loaded.emit(path, resource)
	return resource


## 以懒加载模式预载资源
func preload_resource(path: String, type_hint: String = "") -> void:
	if _resource_cache.has(path) and _resource_cache[path] != null:
		print("resource already loaded: ", path)
		return

	var load_dict: Dictionary = {
		"path": path,
		"type_hint": type_hint,
	}
	_pending_path_list.append(load_dict)


## 清空资源缓存
## [param path] 资源路径，如果为空，则清空所有资源
func unload_resource(path: String = "") -> void:
	if path.is_empty():
		_resource_cache.clear()
		resource_unloaded.emit("")
	elif _resource_cache.has(path):
		_resource_cache.erase(path)
		resource_unloaded.emit(path)


## 获取缓存资源
## [param path] 资源路径
## [return] 缓存中的资源
func get_resource(path: String) -> Resource:
	# 如果资源正在加载，则这里调用直接加载
	if _resource_cache.has(path) and _resource_cache[path] == null:
		_loading_count -= 1
	if _resource_cache.get(path, null) == null:
		_logger.warning("[ResourceManager] cannot get cached resource on %s, reload it!" % path)
		return load_resource(path)
	return _resource_cache.get(path)


## 从对象池获取实例，如果不存在则返回空
## [param id] 实例ID
## [return] 池中的实例
func get_instance(id: StringName) -> Node:
	if _instance_pools.has(id):
		return _instance_pools[id].pop_back()
	return null


## 回收实例到对象池
## [param id] 实例ID
## [param instance] 要回收的实例
func recycle_instance(id: StringName, instance: Node) -> void:
	if not _instance_pools.has(id):
		_instance_pools[id] = []
	if instance.get_parent():
		instance.get_parent().remove_child(instance)
	_instance_pools[id].append(instance)


## 获取对象池中实例的数量，如果为空，计算所有对象池中的实例数量
## [param id] 实例ID
## [return] 池中的实例数量
func get_instance_count(id: StringName = "") -> int:
	if id.is_empty():
		var count: int = 0
		for pool in _instance_pools.values():
			count += pool.size()
		return count
	if not _instance_pools.has(id):
		return 0
	return _instance_pools[id].size()


## 清空对象池，如果为空，清空所有对象池
## [param id] 实例ID
func clear_instance_pool(id: StringName = "") -> void:
	if id.is_empty():
		_instance_pools.clear()
	elif _instance_pools.has(id):
		_instance_pools[id].clear()
		_instance_pools[id].resize(0)
	else:
		push_error("instance pool for id ", id, " not exist.")


## 设置懒加载时间间隔
## [param interval] 时间间隔
func set_lazy_load_interval(interval: float) -> void:
	_lazy_load_interval = interval


func _check_pending() -> void:
	if _pending_path_list.is_empty(): return

	for dict in _pending_path_list:
		if _loading_count >= _max_loading_count: break

		var path: String = dict["path"]
		var type_hint: String = dict["type_hint"]

		ResourceLoader.load_threaded_request(path, type_hint)
		_loading_count += 1
		_resource_cache[path] = null
		_pending_path_list.erase(dict)
		_loading_path_list.append(path)


## 处理懒加载
## [param delta] 时间间隔
func _lazy_load(delta: float) -> void:
	if _loading_count <= 0: return

	# 判断是否需要处理懒加载
	_lazy_load_time += delta
	if _lazy_load_time < _lazy_load_interval: return
	_lazy_load_time -= _lazy_load_interval

	for path in _loading_path_list:
		_lazy_load_process(path)


func _lazy_load_process(path: String) -> void:
	var progress: Array
	var load_status: ResourceLoader.ThreadLoadStatus =\
		ResourceLoader.load_threaded_get_status(path, progress)
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var resource: Resource = ResourceLoader.load_threaded_get(path)
			_resource_cache[path] = resource
			_loading_path_list.erase(path)
			_loading_count -= 1
			resource_loaded.emit(path, resource)
			print("lazy load loaded: ", path)
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var load_percent: float = progress.front() * 100.0
			print("lazy load in progress: %s\t %s%%" % [path, load_percent])
		ResourceLoader.THREAD_LOAD_FAILED:
			_resource_cache.erase(path)
			_loading_path_list.erase(path)
			_loading_count -= 1
			_logger.error("[ResourceManager] lazy load failed: " + path)
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_resource_cache.erase(path)
			_loading_path_list.erase(path)
			_loading_count -= 1
			_logger.error("[ResourceManager] lazy load invalid: " + path)
