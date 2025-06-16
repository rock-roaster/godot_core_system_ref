extends Node
class_name SceneBase


var _scene_save_data: Dictionary
var _init_through_manager: bool = false


func _ready() -> void:
	if _init_through_manager: return
	_on_scene_ready()
	await get_tree().create_timer(0.25).timeout
	_on_scene_switch()


func get_scene_data(key: String, default: Variant = null) -> Variant:
	return _scene_save_data.get(key, default)


func set_scene_data(key: String, value: Variant) -> void:
	_scene_save_data.set(key, value)


func upload_scene_data() -> void:
	System.scene_manager.get_scene_save(self)


func _on_scene_save() -> Dictionary:
	var scene_save: Dictionary = _scene_save()
	_scene_save_data.merge(scene_save, true)
	return _scene_save_data


func _on_scene_init(data: Dictionary) -> void:
	_init_through_manager = true
	_scene_save_data = data
	_scene_init(data)


func _on_scene_restore(data: Dictionary) -> void:
	if data.is_empty() && !_scene_save_data.is_empty():
		_scene_init(_scene_save_data)
	_scene_restore(data)


func _on_scene_ready() -> void:
	_scene_ready()


func _on_scene_switch() -> void:
	_scene_switch()


## 保存场景时调用
func _scene_save() -> Dictionary: return {}
## 初始化场景时调用
func _scene_init(data: Dictionary) -> void: pass
## 恢复场景时调用
func _scene_restore(data: Dictionary) -> void: pass
## 场景进入节点树后调用
func _scene_ready() -> void: pass
## 场景转换完成后调用
func _scene_switch() -> void: pass
