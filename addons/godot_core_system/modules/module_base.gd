extends RefCounted


var _system_node: System:
	get: return System
	set(value): push_error("_system_node is read only.")

var _current_tree: SceneTree:
	get: return _system_node.get_tree()
	set(value): push_error("_current_tree is read only.")

var _current_root: Window:
	get: return _current_tree.get_root()
	set(value): push_error("_current_root is read only.")


func _init() -> void:
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
