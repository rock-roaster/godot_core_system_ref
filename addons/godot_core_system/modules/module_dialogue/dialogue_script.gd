extends RefCounted
class_name DialogueScript


var node_dict: Dictionary[StringName, Node]
var func_dict: Dictionary[StringName, Callable]

var _dialogue_lines: Array[DialogueLine]


func _init(
		_node_dict: Dictionary[StringName, Node] = {},
		_func_dict: Dictionary[StringName, Callable] = {},
		) -> void:

	node_dict = _node_dict
	func_dict = _func_dict

	_dialogue_lines.clear()
	_dialogue_process()
	# 当数据量达到一定程度后，应使用pop_back而非pop_front保证运行速度，
	# 所以将数组颠倒过来后进行提取。
	_dialogue_lines.reverse()


func _dialogue_process() -> void:
	pass


func _dialogue_exit() -> void:
	pass


func get_next_line() -> DialogueLine:
	var next_line: DialogueLine = _dialogue_lines.pop_back()
	return next_line


func add_text(
		text: String,
		auto_advance: bool = false,
		) -> void:

	var new_line: DialogueLine = DialogueLine.new()
	new_line.dialogue_type = DialogueLine.DialogueType.TEXT
	new_line.dialogue_data.set("text", text)
	new_line.dialogue_data.set("auto_advance", auto_advance)
	_dialogue_lines.append(new_line)


func add_callable(
		callable: Callable,
		await_call: bool = false,
		auto_advance: bool = true
		) -> void:

	var new_line: DialogueLine = DialogueLine.new()
	new_line.dialogue_type = DialogueLine.DialogueType.CALLABLE
	new_line.dialogue_data.set("callable", callable)
	new_line.dialogue_data.set("await", await_call)
	new_line.dialogue_data.set("auto_advance", auto_advance)
	_dialogue_lines.append(new_line)
