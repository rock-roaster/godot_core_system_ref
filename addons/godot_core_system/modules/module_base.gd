extends RefCounted


var _current_tree: SceneTree:
	get: return System.get_tree()
	set(value): push_error("_current_tree is read only.")

var _current_root: Window:
	get: return _current_tree.get_root()
	set(value): push_error("_current_root is read only.")


func _init(_data: Dictionary = {}) -> void:
	pass


func _ready() -> void:
	pass


func _exit() -> void:
	pass


func _input(_event: InputEvent) -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass
