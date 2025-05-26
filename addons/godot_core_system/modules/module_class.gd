extends RefCounted
class_name ModuleClass


const ModuleBase: =			preload("module_base.gd")
const ModuleLog: =			preload("module_log/module_log.gd")
const ModuleSave: =			preload("module_save/module_save.gd")
const ModuleConfig: =		preload("module_config/module_config.gd")
const ModuleAudio: =		preload("module_audio/module_audio.gd")
const ModuleEvent: =		preload("module_event/module_event.gd")
const ModuleInput: =		preload("module_input/module_input.gd")
const ModuleResource: =		preload("module_resource/module_resource.gd")
const ModuleEntity: =		preload("module_entity/module_entity.gd")
const ModuleTime: =			preload("module_time/module_time.gd")
const ModuleScene: =		preload("module_scene/module_scene.gd")
const ModuleTag: =			preload("module_tag/module_tag.gd")
const ModuleTrigger: =		preload("module_trigger/module_trigger.gd")
const ModuleThread: =		preload("module_thread/module_thread.gd")

const MODULE_SCRIPTS: Dictionary[StringName, Script] = {
	"module_log":			ModuleLog,
	"module_save":			ModuleSave,
	"module_config":		ModuleConfig,
	"module_resource":		ModuleResource,
	"module_entity":		ModuleEntity,
	"module_scene":			ModuleScene,
	"module_audio":			ModuleAudio,
	"module_input":			ModuleInput,
	"module_time":			ModuleTime,
	"module_event":			ModuleEvent,
	"module_tag":			ModuleTag,
	"module_trigger":		ModuleTrigger,
	"module_thread":		ModuleThread,
}
