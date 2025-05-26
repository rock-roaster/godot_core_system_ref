extends RefCounted


const DEFAULT_CONFIG_HINT: Dictionary[StringName, Dictionary] = {
	"game":
	{
		"first_run":
		{
			"section": "game",
			"name": "first_run",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"default": true,
		},

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

		"resolution":
		{
			"section": "graphics",
			"name": "resolution",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1.0, 0.05",
			"default": 1.0,
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
			"hint_string": "0.0, 12.0, 1.0",
			"default": 12.0,
		},

		"music_volume":
		{
			"section": "audio",
			"name": "music_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 12.0, 1.0",
			"default": 12.0,
		},

		"sound_volume":
		{
			"section": "audio",
			"name": "sound_volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 12.0, 1.0",
			"default": 12.0,
		},
	},

	"input":
	{
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
