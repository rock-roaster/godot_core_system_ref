extends Node


const SETTING_SCRIPT: Script = preload("res://addons/godot_core_system/setting.gd")
const SETTING_INFO_DICT: Dictionary[StringName, Dictionary] = SETTING_SCRIPT.SETTING_INFO_DICT

#region 导入模组脚本
const ModuleBase = ModuleClass.ModuleBase
const ModuleLog = ModuleClass.ModuleLog
const ModuleSave = ModuleClass.ModuleSave
const ModuleConfig = ModuleClass.ModuleConfig
const ModuleResource = ModuleClass.ModuleResource
const ModuleEntity = ModuleClass.ModuleEntity
const ModuleScene = ModuleClass.ModuleScene
const ModuleAudio = ModuleClass.ModuleAudio
const ModuleInput = ModuleClass.ModuleInput
const ModuleTime = ModuleClass.ModuleTime
const ModuleEvent = ModuleClass.ModuleEvent
const ModuleState = ModuleClass.ModuleState
const ModuleTag = ModuleClass.ModuleTag
const ModuleTrigger = ModuleClass.ModuleTrigger
const ModuleThread = ModuleClass.ModuleThread

#const AsyncIOManager = preload("./utils/async_io_manager/async_io_manager.gd")
#endregion

#region 模组变量与getset方法
var logger: ModuleLog:
	get: return get_module("logger")
	set(value): push_error("logger is read-only.")

var save_manager: ModuleSave:
	get: return get_module("save_manager")
	set(value): push_error("save_manager is read-only.")

var config_manager: ModuleConfig:
	get: return get_module("config_manager")
	set(value): push_error("config_manager is read-only.")

var resource_manager: ModuleResource:
	get: return get_module("resource_manager")
	set(value): push_error("resource_manager is read-only.")

var entity_manager: ModuleEntity:
	get: return get_module("entity_manager")
	set(value): push_error("entity_manager is read-only.")

var scene_manager: ModuleScene:
	get: return get_module("scene_manager")
	set(value): push_error("scene_manager is read-only.")

var audio_manager: ModuleAudio:
	get: return get_module("audio_manager")
	set(value): push_error("audio_manager is read-only.")

var input_manager: ModuleInput:
	get: return get_module("input_manager")
	set(value): push_error("input_manager is read-only.")

var time_manager: ModuleTime:
	get: return get_module("time_manager")
	set(value): push_error("time_manager is read-only.")

var event_manager: ModuleEvent:
	get: return get_module("event_manager")
	set(value): push_error("event_manager is read-only.")

var state_manager: ModuleState:
	get: return get_module("state_manager")
	set(value): push_error("state_manager is read-only.")

var tag_manager: ModuleTag:
	get: return get_module("tag_manager")
	set(value): push_error("tag_manager is read-only.")

var trigger_manager: ModuleTrigger:
	get: return get_module("trigger_manager")
	set(value): push_error("trigger_manager is read-only.")

var thread: ModuleThread:
	get: return get_module("thread_manager")
	set(value): push_error("thread_manager is read-only.")
#endregion

var _modules: Dictionary[StringName, ModuleBase]
var _module_scripts: Dictionary[StringName, Script] = {
	"logger": ModuleLog,
	"save_manager": ModuleSave,
	"config_manager": ModuleConfig,
	"resource_manager": ModuleResource,
	"entity_manager": ModuleEntity,
	"scene_manager": ModuleScene,
	"audio_manager": ModuleAudio,
	"input_manager": ModuleInput,
	"time_manager": ModuleTime,
	"event_manager": ModuleEvent,
	"state_manager": ModuleState,
	"tag_manager": ModuleTag,
	"trigger_manager": ModuleTrigger,
	"thread_manager": ModuleThread,
}


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
	var setting_name: String = "godot_core_system/module_enable/" + module_id
	if not ProjectSettings.has_setting(setting_name): return true
	return ProjectSettings.get_setting(setting_name, true)


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


## 设置路径和字典名称里只要填对一个就能得到参数的傻瓜方法
func get_setting_value(setting_name: StringName, default_value: Variant = null) -> Variant:
	return SETTING_SCRIPT.get_setting_value(setting_name, default_value)
