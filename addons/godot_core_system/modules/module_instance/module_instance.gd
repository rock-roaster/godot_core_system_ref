extends "res://addons/godot_core_system/modules/module_base.gd"


## 对象池
var _instance_pools: Dictionary[StringName, Array] = {}


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
	if _instance_pools.has(id):
		return _instance_pools[id].pop_back()
	return null


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
