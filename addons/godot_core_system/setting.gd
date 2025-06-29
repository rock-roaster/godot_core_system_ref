extends RefCounted


const SETTING_MODULE_ENABLE: String = "godot_core_system/module_enable/"
const SETTING_MODULE_LOG: String = "godot_core_system/module_log/"
const SETTING_MODULE_SAVE: String = "godot_core_system/module_save/"
const SETTING_MODULE_CONFIG: String = "godot_core_system/module_config/"
const SETTING_MODULE_TRIGGER: String = "godot_core_system/module_trigger/"

const SETTING_INFO_DICT: Dictionary[StringName, Dictionary] = {

#region ModuleEnable
	"module_enable/module_log":
	{
		"name": SETTING_MODULE_ENABLE + "logger",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_save":
	{
		"name": SETTING_MODULE_ENABLE + "save_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_config":
	{
		"name": SETTING_MODULE_ENABLE + "config_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_resource":
	{
		"name": SETTING_MODULE_ENABLE + "resource_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_entity":
	{
		"name": SETTING_MODULE_ENABLE + "entity_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_scene":
	{
		"name": SETTING_MODULE_ENABLE + "scene_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_audio":
	{
		"name": SETTING_MODULE_ENABLE + "audio_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_input":
	{
		"name": SETTING_MODULE_ENABLE + "input_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_time":
	{
		"name": SETTING_MODULE_ENABLE + "time_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_event":
	{
		"name": SETTING_MODULE_ENABLE + "event_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_tag":
	{
		"name": SETTING_MODULE_ENABLE + "tag_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_trigger":
	{
		"name": SETTING_MODULE_ENABLE + "trigger_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},

	"module_enable/module_thread":
	{
		"name": SETTING_MODULE_ENABLE + "thread_manager",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},
#endregion

#region ModuleLog
	"module_log/color_debug":
	{
		"name": SETTING_MODULE_LOG + "color_debug",
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": Color.DARK_GRAY,
	},

	"module_log/color_info":
	{
		"name": SETTING_MODULE_LOG + "color_info",
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": Color.WHITE,
	},

	"module_log/color_warning":
	{
		"name": SETTING_MODULE_LOG + "color_warning",
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": Color.YELLOW,
	},

	"module_log/color_error":
	{
		"name": SETTING_MODULE_LOG + "color_error",
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": Color.RED,
	},

	"module_log/color_fatal":
	{
		"name": SETTING_MODULE_LOG + "color_fatal",
		"type": TYPE_COLOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": Color(0.5, 0, 0),
	},
#endregion

#region ModuleSave
	"module_save/save_directory":
	{
		"name": SETTING_MODULE_SAVE + "save_directory",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
		"hint_string": "存档路径",
		"basic": true,
		"default": "user://saves",  # 添加默认值
	},

	"module_save/save_group":
	{
		"name": SETTING_MODULE_SAVE + "save_group",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": "savable",
	},

	"module_save/serialization_format":
	{
		"name": SETTING_MODULE_SAVE + "serialization_format",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "json,binary,resource",
		"basic": true,
		"default": "json",
	},

	"module_save/auto_save/enabled":
	{
		"name": SETTING_MODULE_SAVE + "auto_save/" + "enabled",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": false,
	},

	"module_save/auto_save/max_saves":
	{
		"name": SETTING_MODULE_SAVE + "auto_save/" + "max_saves",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1,10,1,or_greater",
		"basic": true,
		"default": 1,
	},

	"module_save/auto_save/interval_seconds":
	{
		"name": SETTING_MODULE_SAVE + "auto_save/" + "interval_seconds",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.0,600.0,1.0,or_greater",
		"basic": true,
		"default": 300.0,
	},

	"module_save/auto_save/name_prefix":
	{
		"name": SETTING_MODULE_SAVE + "auto_save/" + "name_prefix",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": "save_auto_",
	},
#endregion

#region ModuleConfig
	"module_config/save_path":
	{
		"name": SETTING_MODULE_CONFIG + "save_path",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "配置文件路径",
		"basic": true,
		"default": "user://config.cfg",
	},

	"module_config/auto_save_enabled":
	{
		"name": SETTING_MODULE_CONFIG + "auto_save_enabled",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": false,
	},
#endregion

#region ModuleTrigger
	"module_trigger/subscribe_event_bus":
	{
		"name": SETTING_MODULE_TRIGGER + "subscribe_event_bus",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"basic": true,
		"default": true,
	},
#endregion

}


## 设置路径和字典名称里只要填对一个就能得到参数的傻瓜方法
static func get_setting_value(setting_name: StringName, default_value: Variant = null) -> Variant:
	var setting_dict: Dictionary = {}

	if SETTING_INFO_DICT.has(setting_name):
		setting_dict = SETTING_INFO_DICT.get(setting_name)
		setting_name = setting_dict.get("name")

	if setting_dict.is_empty():
		for dict in SETTING_INFO_DICT.values():
			if dict.get("name") == setting_name:
				setting_dict = dict
				break

	if setting_dict.has("default") && default_value == null:
		default_value = setting_dict.get("default")

	return ProjectSettings.get_setting(setting_name, default_value)
