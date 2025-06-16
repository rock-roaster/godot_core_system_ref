extends "../module_base.gd"

## 配置管理器

# 信号
## 配置加载
signal config_loaded
## 配置保存
signal config_saved
## 配置重置
signal config_reset

const DefaultConfig: Script = preload("default_config.gd")

## 当前配置
var _config_file: ConfigFile
## 是否已修改
var _modified: bool

## 配置文件路径
var _config_path: String:
	get: return _system.get_setting_value("module_config/save_path")

## 是否自动保存
var _auto_save: bool:
	get: return _system.get_setting_value("module_config/auto_save_enabled")

## 线程管理器
var _thread_manager: ModuleClass.ModuleThread:
	get: return _system.thread


func _init() -> void:
	_config_file = ConfigFile.new()
	_modified = false
	_load_config_async()


func _ready() -> void:
	_setup_config.call_deferred()


func _exit() -> void:
	if _auto_save and _modified:
		save_config()
	_thread_manager.unload_thread("config_thread")


func _setup_config() -> void:
	var master_volume: float = get_value("audio", "master_volume", 12.0)
	_system.audio_manager.set_volume(&"Master", master_volume / 12.0)
	var music_volume: float = get_value("audio", "music_volume", 12.0)
	_system.audio_manager.set_volume(&"Music", music_volume / 12.0)
	var sound_volume: float = get_value("audio", "sound_volume", 12.0)
	_system.audio_manager.set_volume(&"Sound", sound_volume / 12.0)
	var voice_volume: float = get_value("audio", "voice_volume", 12.0)
	_system.audio_manager.set_volume(&"Voice", voice_volume / 12.0)

	var resolution: float = get_value("graphics", "resolution", 1.0)
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(screen_size * resolution)

	var fullscreen: bool = get_value("graphics", "fullscreen", true)
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_current_root.get_window().move_to_center()


## 设置配置值
## [param section] 配置段
## [param key] 键
## [param value] 值
func set_value(section: String, key: String, value: Variant) -> void:
	_config_file.set_value(section, key, value)
	_modified = true
	if _auto_save:
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
	if _auto_save:
		save_config()


## 重置配置
## [param callback] 回调函数
func reset_config(callback: Callable = Callable()) -> void:
	_config_file = DefaultConfig.get_default_config_file()

	_modified = true
	config_reset.emit()

	if _auto_save:
		save_config(callback)
	elif callback.is_valid():
		callback.call()


## 加载配置
## [param callback] 回调函数
func load_config(callback: Callable = Callable()) -> void:
	_thread_manager.add_task("config_thread", _load_config_async, callback)


## 保存配置
## [param callback] 回调函数
func save_config(callback: Callable = Callable()) -> void:
	_thread_manager.add_task("config_thread", _save_config_async, callback)


func _load_config_async() -> void:
	var error: Error = _config_file.load(_config_path)
	if error != OK:
		_config_file = DefaultConfig.get_default_config_file()
	_modified = false
	config_loaded.emit()
	_thread_manager.next_step("config_thread")


func _save_config_async() -> void:
	var error: Error = _config_file.save(_config_path)
	if error == OK:
		_modified = false
		config_saved.emit()
	_thread_manager.next_step("config_thread")
