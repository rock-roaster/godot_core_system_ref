extends SceneBase


var scene_path: String = "res://tester/scene_manager_tester/scene_01.tscn"

var info_text: String

var scene_data: Dictionary = {
	"init_info": "Init! 01",
	"restore_info": "Restore! 01"
}

var scene_save: Dictionary

@onready var information: Label = $Information


func _ready() -> void:
	System.scene_manager.preload_scene(scene_path)
	information.text = info_text


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		_change_scene()


func _save_scene() -> Dictionary:
	return scene_save


func _init_scene(data: Dictionary) -> void:
	info_text = data.get("init_info")


func _restore_scene(data: Dictionary) -> void:
	scene_save = data
	information.text = data.get("restore_info")


func _change_scene() -> void:
	System.scene_manager.change_scene_dissolve(scene_path, scene_data, true)
