extends "../module_base.gd"

## 实体管理器
## 负责管理实体的生命周期和资源加载

## 实体加载完成信号
signal entity_loaded(entity_id: StringName, entity: PackedScene)
signal entity_unloaded(entity_id: StringName)
## 实体销毁信号
signal entity_created(entity_id: StringName, entity: Node)
signal entity_destroyed(entity_id: StringName, entity: Node)

## 实体资源缓存
var _entity_resource_cache: Dictionary[StringName, PackedScene] = {}
## 实体ID路径映射
var _entity_path_map: Dictionary[StringName, String] = {}

## 对象池
var _instance_pools: Dictionary[StringName, Array] = {}

var _resource_manager: ModuleClass.ModuleResource:
	get: return _system.resource_manager


func _exit() -> void:
	clear_instance_pool()


func _on_resource_loaded(resource_path: String, resource: Resource) -> void:
	if resource is not PackedScene: return
	var entity_id: Variant = _entity_path_map.find_key(resource_path)
	if not entity_id: return

	if _entity_resource_cache.has(entity_id): return
	_entity_resource_cache[entity_id] = resource
	entity_loaded.emit(entity_id, resource)


func _on_resource_unloaded(resource_path: String) -> void:
	var entity_id: Variant = _entity_path_map.find_key(resource_path)
	if not entity_id: return
	_entity_resource_cache.erase(entity_id)
	entity_unloaded.emit(entity_id)


## 获取实体场景
func get_entity_scene(entity_id: StringName) -> PackedScene:
	return _entity_resource_cache.get(entity_id)


## 加载实体
## [param entity_id] 实体ID
## [param scene_path] 场景路径
## [param load_mode] 加载模式
## [return] 加载的实体
func load_entity(entity_id: StringName, scene_path: String) -> PackedScene:
	if _entity_resource_cache.has(entity_id):
		push_warning("实体已存在: %s" % entity_id)
		return _entity_resource_cache[entity_id]

	_entity_path_map[entity_id] = scene_path
	var scene: PackedScene = _resource_manager.load_resource(scene_path)
	if not scene:
		push_error("无法加载实体场景: %s" % scene_path)
		return null

	_entity_resource_cache[entity_id] = scene
	entity_loaded.emit(entity_id, scene)
	return scene


## 卸载实体
## [param entity_id] 实体ID
func unload_entity(entity_id: StringName) -> void:
	if not _entity_resource_cache.has(entity_id):
		push_warning("实体不存在: %s" % entity_id)
		return
	_resource_manager.unload_resource(_entity_path_map[entity_id])


## 创建实体
## [param entity_id] 实体ID
## [param parent] 父节点
func create_entity(
	entity_id: StringName,
	entity_data: Dictionary = {},
	parent: Node = null,
	) -> Node:
	var instance: Node = get_instance(_entity_path_map[entity_id])
	if not instance:
		instance = get_entity_scene(entity_id).instantiate()

	if not instance or not instance is Node:
		push_error("实体实例不是 Node 类型: %s" % entity_id)
		return

	if parent:
		parent.add_child(instance)

	## 初始化实体
	if instance.has_method("_init_node"):
		instance.call("_init_node", entity_data)

	entity_created.emit(entity_id, instance)
	return instance


## 更新实体
## [param entity_id] 实体ID
## [param instance] 要更新的实体
func update_entity(
	instance: Node,
	entity_data: Dictionary = {},
	) -> void:
	if instance.has_method("_update_node"):
		instance.call("_update_node", entity_data)


## 销毁实体
## [param entity_id] 实体ID
## [param instance] 要销毁的实体
func destroy_entity(entity_id: StringName, instance: Node) -> void:
	if instance.has_method("_destroy_node"):
		instance.call("_destroy_node")
	recycle_instance(_entity_path_map[entity_id], instance)
	entity_destroyed.emit(entity_id, instance)


## 清理所有实体
func clear_entities() -> void:
	for entity_id in _entity_resource_cache.keys():
		clear_instance_pool(_entity_path_map[entity_id])


#region instance pool
## 创建对象池
## [param id] 实例ID
## [param instance] 要创建的实例
## [param count] 实例的初始数量
## [param duplicate_flags] 实例的复制模式
func create_instance_pool(
	id: StringName,
	instance: Node,
	count: int = 1,
	duplicate_flags: Node.DuplicateFlags = 15,
	) -> void:

	if not _instance_pools.has(id):
		_instance_pools[id] = []

	if count <= 0: return
	for i in count:
		var new_instance: Node = instance.duplicate(duplicate_flags)
		_instance_pools[id].append(new_instance)


## 从对象池获取实例，如果不存在则返回空
## [param id] 实例ID
## [return] 池中的实例
func get_instance(id: StringName) -> Node:
	if not _instance_pools.has(id):
		return null
	return _instance_pools[id].pop_back()


## 回收实例到对象池
## [param id] 实例ID
## [param instance] 要回收的实例
func recycle_instance(id: StringName, instance: Node) -> void:
	if not _instance_pools.has(id):
		_instance_pools[id] = []
	if instance.get_parent() != null:
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
		for pool_array in _instance_pools.values():
			pool_array.map(_free_instance)
		_instance_pools.clear()
		return

	if _instance_pools.has(id):
		_instance_pools[id].map(_free_instance)
		_instance_pools[id].clear()
	else:
		push_error("instance pool for id ", id, " not exist.")


func _free_instance(value: Node) -> void: value.free()
#endregion
