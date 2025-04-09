extends "res://addons/godot_core_system/modules/module_base.gd"

## 配置管理器

# 信号
## 配置加载
signal config_loaded
## 配置保存
signal config_saved
## 配置重置
signal config_reset

const DefaultConfig: Script = preload(
	"res://addons/godot_core_system/modules/module_serialization/module_config/default_config.gd")

## 配置文件路径
@export var config_path: String:
	get: return System.get_setting_value("module_config/save_path")
	set(value): System.logger.error("read-only")

## 是否自动保存
@export var auto_save: bool:
	get: return System.get_setting_value("module_config/auto_save_enabled")
	set(value): System.logger.error("read-only")

## 是否已修改
var _modified: bool
## 当前配置
var _config_file: ConfigFile
## 异步IO管理器
var _thread_manager: ModuleClass.ModuleThread


func _init(_data: Dictionary = {}):
	_modified = false
	_config_file = DefaultConfig.get_default_config_file()
	_thread_manager = System.thread


func _exit() -> void:
	if auto_save and _modified:
		save_config()

	_thread_manager.unload_thread("save_config")
	_thread_manager.unload_thread("load_config")


## 加载配置
## [param callback] 回调函数
func load_config(callback: Callable = Callable()) -> void:
	_thread_manager.add_task("load_config", load_config_async, callback)


func load_config_async() -> void:
	var error: Error = _config_file.load(config_path)
	if error != OK:
		_config_file = DefaultConfig.get_default_config_file()
	_modified = false
	config_loaded.emit()
	_thread_manager.next_step("load_config")


## 保存配置
## [param callback] 回调函数
func save_config(callback: Callable = Callable()) -> void:
	_thread_manager.add_task("save_config", save_config_async, callback)


func save_config_async() -> void:
	var error: Error = _config_file.save(config_path)
	if error == OK:
		_modified = false
		config_saved.emit()
	_thread_manager.next_step("save_config")


## 重置配置
## [param callback] 回调函数
func reset_config(callback: Callable = Callable()) -> void:
	_config_file = DefaultConfig.get_default_config_file()

	_modified = true
	config_reset.emit()

	if auto_save:
		save_config(callback)
	else:
		if callback.is_valid():
			callback.call()


## 设置配置值
## [param section] 配置段
## [param key] 键
## [param value] 值
func set_value(section: String, key: String, value: Variant) -> void:
	_config_file.set_value(section, key, value)
	_modified = true
	if auto_save:
		save_config()


## 获取配置值
## [param section] 配置段
## [param key] 键
## [param default_value] 默认值
## [return] 值
func get_value(section: String, key: String, default_value: Variant = null) -> Variant:
	var value: Variant = _config_file.get_value(section, key, default_value)
	return value


## 删除配置值
## [param section] 配置段
## [param key] 键
func erase_value(section: String, key: String) -> void:
	if not _config_file.has_section_key(section, key): return
	_config_file.set_value(section, key, null)
	if auto_save:
		save_config()
