extends Node


const Setting: Script = preload("setting.gd")
const ModuleBase: Script = ModuleClass.ModuleBase

#region 获取模组实例
var logger: ModuleClass.ModuleLog:
	get: return get_module("module_log")
	set(value): push_error("module_log is read-only.")

var save_manager: ModuleClass.ModuleSave:
	get: return get_module("module_save")
	set(value): push_error("module_save is read-only.")

var config_manager: ModuleClass.ModuleConfig:
	get: return get_module("module_config")
	set(value): push_error("module_config is read-only.")

var resource_manager: ModuleClass.ModuleResource:
	get: return get_module("module_resource")
	set(value): push_error("module_resource is read-only.")

var entity_manager: ModuleClass.ModuleEntity:
	get: return get_module("module_entity")
	set(value): push_error("module_entity is read-only.")

var scene_manager: ModuleClass.ModuleScene:
	get: return get_module("module_scene")
	set(value): push_error("module_scene is read-only.")

var audio_manager: ModuleClass.ModuleAudio:
	get: return get_module("module_audio")
	set(value): push_error("module_audio is read-only.")

var input_manager: ModuleClass.ModuleInput:
	get: return get_module("module_input")
	set(value): push_error("module_input is read-only.")

var time_manager: ModuleClass.ModuleTime:
	get: return get_module("module_time")
	set(value): push_error("module_time is read-only.")

var event_manager: ModuleClass.ModuleEvent:
	get: return get_module("module_event")
	set(value): push_error("module_event is read-only.")

var tag_manager: ModuleClass.ModuleTag:
	get: return get_module("module_tag")
	set(value): push_error("module_tag is read-only.")

var trigger_manager: ModuleClass.ModuleTrigger:
	get: return get_module("module_trigger")
	set(value): push_error("module_trigger is read-only.")

var thread: ModuleClass.ModuleThread:
	get: return get_module("module_thread")
	set(value): push_error("module_thread is read-only.")
#endregion

var _modules: Dictionary[StringName, ModuleBase]
var _module_scripts: Dictionary[StringName, Script]


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_module_scripts = ModuleClass.MODULE_SCRIPTS


func _ready() -> void:
	input_manager.import()
	config_manager.import()


func _input(event: InputEvent) -> void:
	for module in _modules.values() as Array[ModuleBase]:
		module._input(event)


func _process(delta: float) -> void:
	for module in _modules.values() as Array[ModuleBase]:
		module._process(delta)


func _physics_process(delta: float) -> void:
	for module in _modules.values() as Array[ModuleBase]:
		module._physics_process(delta)


## 获取模块
func get_module(module_id: StringName) -> ModuleBase:
	if not _modules.has(module_id):
		if is_module_enabled(module_id):
			_modules[module_id] = _create_module(module_id)
		else:
			push_error("模块未启用：" + module_id)
			return null
	return _modules[module_id]


## 检查模块是否启用
func is_module_enabled(module_id: StringName) -> bool:
	var setting_name: String = "module_enable/" + module_id
	var setting_value: Variant = get_setting_value(setting_name)
	if setting_value == null: return true
	return setting_value


## 设置路径和字典名称里只要填对一个就能得到参数的傻瓜方法
func get_setting_value(setting_name: StringName, default_value: Variant = null) -> Variant:
	return Setting.get_setting_value(setting_name, default_value)


## 创建模块实例
func _create_module(module_id: StringName) -> ModuleBase:
	var script: Script = _module_scripts[module_id]
	if not script:
		push_error("无法加载模块脚本：" + module_id)
		return null

	var module: ModuleBase = script.new()
	if not module:
		push_error("无法创建模块实例：" + module_id)
		return null

	_modules[module_id] = module
	module._ready()
	return module


## 手动卸载指定模快
func _unload_module(module_id: StringName) -> void:
	if not _modules.has(module_id):
		print(module_id, "模块未被实例化")
		return

	var module: ModuleBase = _modules[module_id]
	var instance_id: int = module.get_instance_id()
	module._exit()
	_modules.erase(module_id)
	print("卸载模块实例：%s id%s" % [module_id, instance_id])
