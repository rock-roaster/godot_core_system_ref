extends RefCounted


const DEFAULT_CONFIG_HINT: Dictionary[StringName, Dictionary] = {
	"game":
	{
		"language":
		{
			"section": "game",
			"name": "language",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "en,zh_CN,zh_TW",
			"default": "en",
		},

		"difficulty":
		{
			"section": "game",
			"name": "difficulty",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "easy,normal,hard",
			"default": "normal",
		},

		"first_run":
		{
			"section": "game",
			"name": "first_run",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},
	},

	"graphics":
	{
		"fullscreen":
		{
			"section": "graphics",
			"name": "fullscreen",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": false,
		},

		"vsync":
		{
			"section": "graphics",
			"name": "vsync",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"resolution":
		{
			"section": "graphics",
			"name": "resolution",
			"type": TYPE_VECTOR2I,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "",
			"default": Vector2i(1920, 1080),
		},

		"quality":
		{
			"section": "graphics",
			"name": "quality",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "low,medium,high",
			"default": "high",
		},
	},

	"audio":
	{
		"master_volume":
		{
			"section": "audio",
			"name": "master_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.01",
			"default": 1.0,
		},

		"music_volume":
		{
			"section": "audio",
			"name": "music_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.01",
			"default": 1.0,
		},

		"sound_volume":
		{
			"section": "audio",
			"name": "sound_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.01",
			"default": 1.0,
		},

		"voice_volume":
		{
			"section": "audio",
			"name": "voice_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.01",
			"default": 1.0,
		},

		"mute":
		{
			"section": "audio",
			"name": "mute",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": false,
		},
	},

	"input":
	{
		"mouse_sensitivity":
		{
			"section": "input",
			"name": "mouse_sensitivity",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.01",
			"default": 1.0,
		},

		"gamepad_enabled":
		{
			"section": "input",
			"name": "gamepad_enabled",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"vibration_enabled":
		{
			"section": "input",
			"name": "vibration_enabled",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},
	},

	"gameplay":
	{
		"tutorial_enabled":
		{
			"section": "gameplay",
			"name": "tutorial_enabled",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"auto_save":
		{
			"section": "gameplay",
			"name": "auto_save",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"auto_save_interval":
		{
			"section": "gameplay",
			"name": "auto_save_interval",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0, 300, 1, or_greater",
			"default": 300,
		},

		"show_damage_numbers":
		{
			"section": "gameplay",
			"name": "show_damage_numbers",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"show_floating_text":
		{
			"section": "gameplay",
			"name": "show_floating_text",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},
	},

	"accessibility":
	{
		"subtitles":
		{
			"section": "accessibility",
			"name": "subtitles",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"screen_shake":
		{
			"section": "accessibility",
			"name": "screen_shake",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"text_size":
		{
			"section": "accessibility",
			"name": "text_size",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "low,medium,high",
			"default": "medium",
		},
	},

	"debug":
	{
		"logging_enabled":
		{
			"section": "debug",
			"name": "logging_enabled",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

		"show_fps":
		{
			"section": "debug",
			"name": "show_fps",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": false,
		},

		"show_debug_info":
		{
			"section": "debug",
			"name": "show_debug_info",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": false,
		},
	},
}


## 获取默认配置
static func get_default_config() -> Dictionary:
	return DEFAULT_CONFIG_HINT


## 获取默认配置文件类
static func get_default_config_file() -> ConfigFile:
	var config_file: ConfigFile = ConfigFile.new()
	for section_dict in DEFAULT_CONFIG_HINT.values() as Array[Dictionary]:
		for hint_dict in section_dict.values() as Array[Dictionary]:
			var config_section: String = hint_dict.get("section")
			var config_key: String = hint_dict.get("name")
			var config_value: Variant = hint_dict.get("default")
			config_file.set_value(config_section, config_key, config_value)
	return config_file
