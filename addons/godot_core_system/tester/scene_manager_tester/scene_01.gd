extends SceneBase


var scene_path: String = "res://addons/godot_core_system/tester/scene_manager_tester/scene_02.tscn"

var info_text: String

var scene_data: Dictionary = {
	"init_info": "Init! 02",
	"restore_info": "Restore! 02"
}

var scene_save: Dictionary

@onready var information: Label = $Information


func _ready() -> void:
	System.scene_manager.preload_scene(scene_path)
	information.text = info_text

	System.instance_pool.create_instance_pool("01", information, 10, true)
	for i in 10:
		add_child(System.instance_pool.get_instance("01"))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		_change_scene()


func _init_scene(data: Dictionary) -> void:
	info_text = data.get("init_info")


func _restore_scene(data: Dictionary) -> void:
	scene_save = data
	information.text = data.get("restore_info")


func _save_scene() -> Dictionary:
	return scene_save


func _change_scene() -> void:
	System.scene_manager.change_scene_fade(
		scene_path,
		scene_data,
		true,
	)
	System.instance_pool.clear_instance_pool("01")
