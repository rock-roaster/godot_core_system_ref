extends "res://addons/godot_core_system/modules/module_base.gd"

## 场景管理器
## 这是一个场景管理系统，提供了与Godot原生场景切换相似的功能，但增加了以下特性：
## 1. 场景切换时的过渡效果
## 2. 场景状态的保存和恢复（场景栈）
## 3. 异步加载场景
## 4. 预加载场景功能

# 信号
## 场景预加载完成
signal scene_preloaded(scene_path: String)
## 开始加载场景
signal scene_loading_started(scene_path: String)
## 场景切换
signal scene_changed(old_scene: Node, new_scene: Node)
## 结束加载场景
signal scene_loading_finished
## 场景数据保存
signal scene_saved(scene_path: String, dict: Dictionary)

# 属性
## 场景栈
## 每个元素的结构为:
## {
##     "scene_node": Node,          # 场景节点
##     "scene_data": Dictionary,    # 场景数据
## }
var _scene_stack: Dictionary[String, Dictionary] = {}
## 预载场景路径
var _preloaded_scenes: Array[String] = []

## 是否正在切换场景
var _is_switching: bool = false
## 转场效果实例
var _transitions: Dictionary = {}

## 转场层
var _transition_layer: CanvasLayer

## 当前场景
var _current_scene: Node:
	get: return _current_tree.get_current_scene()
	set(value): _current_tree.set_current_scene.call_deferred(value)

## 资源管理器
var _resource_manager: ModuleClass.ModuleResource:
	get: return _system.resource_manager

## 示例管理器
var _entity_manager: ModuleClass.ModuleEntity:
	get: return _system.entity_manager

## 日志管理器
var _logger: ModuleClass.ModuleLog:
	get: return _system.logger


func _ready() -> void:
	# 设置默认转场遮罩
	_setup_transition_layer()
	# 初始化默认转场效果
	_setup_default_transitions()


func _exit() -> void:
	_clear_scene_stack()


func _on_resource_loaded(path: String, resource: Resource) -> void:
	if resource is not PackedScene: return
	scene_preloaded.emit(path)

	if _preloaded_scenes.has(path): return
	_preloaded_scenes.append(path)


func _on_resource_unloaded(path: String) -> void:
	_preloaded_scenes.erase(path)


## 设置转场层
func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.name = "TransitionLayer"
	_transition_layer.layer = 128
	_system.add_child(_transition_layer)


## 设置默认转场效果
func _setup_default_transitions() -> void:
	register_transition("fade", FadeTransition.new())
	register_transition("cross", CrossTransition.new())
	register_transition("slide", SlideTransition.new())
	register_transition("dissolve", DissolveTransition.new())


## 确保所有栈中的孤儿节点均被释放
func _clear_scene_stack() -> void:
	for stack in _scene_stack.values():
		var stack_node: Node = stack.get("scene_node")
		stack_node.queue_free()
	_scene_stack.clear()


## 注册自定义转场效果
## @param effect 转场效果类型
## @param transition 转场效果实例
func register_transition(effect: StringName, transition: BaseTransition) -> void:
	if transition == null or effect.is_empty(): return
	_transitions[effect] = transition
	transition._init_transition(_transition_layer)


## 获取当前场景
func get_current_scene() -> Node:
	return _current_scene


## 预加载场景
## @param scene_path 场景路径
func preload_scene(scene_path: String) -> void:
	_resource_manager.preload_resource(scene_path)


## 卸载预加载场景
func unload_scene(scene_path: String = "") -> void:
	if scene_path.is_empty():
		for path in _preloaded_scenes:
			_resource_manager.unload_resource(path)
		return

	if _preloaded_scenes.has(scene_path):
		_resource_manager.unload_resource(scene_path)


func _get_scene_node(scene_path: String, scene_data: Dictionary = {}) -> Node:
	var new_scene: Node

	# 检查场景栈中是否已存在该场景
	if _scene_stack.has(scene_path):
		var stack_data: Dictionary = _scene_stack[scene_path]
		new_scene = stack_data.get("scene_node") as Node
		_scene_stack.erase(scene_path)

	# 检查对象池中是否已存在该场景
	if new_scene == null:
		new_scene = _entity_manager.get_instance(scene_path)

	# 当场景未被释放时返回
	if is_instance_valid(new_scene):
		# 检查场景复原函数
		if new_scene.has_method("_restore_scene"):
			new_scene.call("_restore_scene", scene_data)
		if new_scene is CanvasItem:
			new_scene.move_to_front()
		return new_scene

	# 从资源管理器中重构场景
	if new_scene == null:
		var packed_scene: PackedScene = _resource_manager.get_resource(scene_path)
		new_scene = packed_scene.instantiate()

	# 检查场景构造函数
	if new_scene != null && new_scene.has_method("_init_scene"):
		new_scene.call("_init_scene", scene_data)

	return new_scene


func _get_scene_save(scene: Node) -> Dictionary:
	var scene_data: Dictionary = scene.call("_save_scene") as Dictionary\
		if scene.has_method("_save_scene") else {}
	if not scene_data.is_empty():
		scene_saved.emit(scene.scene_file_path, scene_data)
	return scene_data


func push_scene_to_stack(scene: Node) -> void:
	var scene_path: String = scene.scene_file_path
	var scene_data: Dictionary = _get_scene_save(scene)

	# 保存当前场景到栈
	_scene_stack.set(
		scene_path,
		{
			"scene_node": scene,
			"scene_data": scene_data,
		}
	)
	scene.get_parent().remove_child(scene)


func change_scene_fade(
	scene_path: String,
	scene_data: Dictionary = {},
	push_to_stack: bool = false,
	) -> void:
	await change_scene(scene_path, scene_data, push_to_stack, "fade")


func change_scene_cross(
	scene_path: String,
	scene_data: Dictionary = {},
	push_to_stack: bool = false,
	) -> void:
	await change_scene(scene_path, scene_data, push_to_stack, "cross")


func change_scene_slide(
	scene_path: String,
	scene_data: Dictionary = {},
	push_to_stack: bool = false,
	) -> void:
	await change_scene(scene_path, scene_data, push_to_stack, "slide")


func change_scene_dissolve(
	scene_path: String,
	scene_data: Dictionary = {},
	push_to_stack: bool = false,
	) -> void:
	await change_scene(scene_path, scene_data, push_to_stack, "dissolve")


## 异步切换场景
## [param scene_path] 场景路径
## [param scene_data] 场景数据
## [param push_to_stack] 是否保存当前场景到栈
## [param effect] 转场效果
## [param duration] 转场持续时间
## [param callback] 切换完成回调
func change_scene(
	scene_path: String,
	scene_data: Dictionary = {},
	push_to_stack: bool = false,
	effect: StringName = "",
	duration: float = 0.5,
	) -> void:

	# 防止同时切换多个场景
	if _is_switching:
		_logger.warning("Scene switching, ignoring request in: %s" % scene_path)
		return

	_is_switching = true
	scene_loading_started.emit(scene_path)

	var new_scene: Node = _get_scene_node(scene_path, scene_data)
	if new_scene == null:
		_logger.error("Failed to load scene: %s" % scene_path)
		_is_switching = false
		return

	await _do_scene_switch(new_scene, push_to_stack, effect, duration)
	unload_scene(scene_path)
	_is_switching = false
	scene_loading_finished.emit(scene_path)


## 子场景管理
## [param parent_node] 父节点
## [param scene_path] 场景路径
## [param scene_data] 场景数据
## [return] 子场景
func add_sub_scene(
	parent_node: Node,
	scene_path: String,
	scene_data: Dictionary = {},
	) -> Node:

	var new_scene: Node = _get_scene_node(scene_path, scene_data)
	if new_scene == null:
		_logger.error("Failed to add sub scene: %s" % scene_path)
		return

	parent_node.add_child(new_scene)
	return new_scene


## 开始转场效果
## @param effect 转场效果
## @param duration 转场持续时间
func _start_transition(effect: StringName, duration: float) -> void:
	if _transitions.has(effect):
		await _transitions[effect].start(duration)
	else:
		_logger.warning("Transition effect not found: %d" % effect)


## 结束转场效果
## @param effect 转场效果
## @param duration 转场持续时间
func _end_transition(effect: StringName, duration: float) -> void:
	if _transitions.has(effect):
		await _transitions[effect].end(duration)
	else:
		_logger.warning("Transition effect not found: %d" % effect)


## 私有方法：执行场景切换
## [param new_scene] 新场景
## [param effect] 转场效果
## [param duration] 持续时间
## [param callback] 回调
## [param save_current] 是否保存当前场景
func _do_scene_switch(
	new_scene: Node,
	push_to_stack: bool,
	effect: StringName,
	duration: float,
	) -> void:

	# 开始转场效果
	if not effect.is_empty():
		await _start_transition(effect, duration)

	# 添加新场景
	if not new_scene.get_parent():
		_current_root.add_child.call_deferred(new_scene)

	var old_scene: Node = _current_scene
	_current_scene = new_scene

	if old_scene != null:
		if push_to_stack:
			# 保存当前场景到栈
			push_scene_to_stack(old_scene)
		else:
			# 如果不需要保存状态，则直接销毁当前场景
			_get_scene_save(old_scene)
			old_scene.get_parent().remove_child.call_deferred(old_scene)
			old_scene.queue_free.call_deferred()

	# 结束转场效果
	if not effect.is_empty():
		await _end_transition(effect, duration)

	## 场景切换后强制更新新场景的相机
	_update_new_scene_camera.call_deferred(new_scene)
	scene_changed.emit(old_scene, new_scene)


func _update_new_scene_camera(new_scene: Node) -> void:
	if new_scene == null:
		push_error("new_scene is null!")
		return

	var new_scene_viewport: Viewport = new_scene.get_viewport()
	if new_scene_viewport != null:\
	if new_scene_viewport.get_camera_2d() != null:
		new_scene_viewport.get_camera_2d().force_update_scroll()
		new_scene_viewport.get_camera_2d().force_update_transform()

	## 待补充3D相机有关设置。下面注释代码无法确定是否有效。需要进一步测试
	#if new_scene_viewport != null:
		#if new_scene_viewport.get_camera_3d() != null:
			#new_scene_viewport.get_camera_3d().force_update_transform()
