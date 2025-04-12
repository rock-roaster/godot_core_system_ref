extends "res://addons/godot_core_system/modules/module_base.gd"


signal dialogue_script_finished(script: DialogueScript)
signal dialogue_line_pushed(line: DialogueLine)
signal dialogue_line_finished(line: DialogueLine)

var _dialogue_line_processing: DialogueLine
var _dialogue_script_processing: DialogueScript

var _ready_to_push: bool

var _maximum_history_line: int = 100
var _dialogue_line_history: Array[DialogueLine]


func _init() -> void:
	_ready_to_push = false


func load_dialogue_script(
		path: String,
		node_dict: Dictionary[StringName, Node] = {},
		func_dict: Dictionary[StringName, Callable] = {},
		) -> void:
	var new_script_resource: GDScript = ResourceLoader.load(path, "GDScript")
	var new_dialogue_script: DialogueScript = new_script_resource.new(node_dict, func_dict)

	if new_dialogue_script is not DialogueScript: return
	_dialogue_script_processing = new_dialogue_script
	_ready_to_push = true


func get_next_line() -> DialogueLine:
	if not _ready_to_push: return
	if _dialogue_script_processing == null: return

	_ready_to_push = false
	var next_line: DialogueLine = _dialogue_script_processing.get_next_line()
	_dialogue_line_processing = next_line

	# 当对话脚本运行完毕
	if next_line == null:
		dialogue_script_finished.emit(_dialogue_script_processing)
		_dialogue_script_processing = null
		return

	dialogue_line_pushed.emit(next_line)

	# 将推出的对话行保存至运行对话行
	_dialogue_line_process(next_line)

	return next_line


## 在每个对话行运行完成后调用该函数以允许推进对话，不建议通过input输入手动调用。
func _finish_line() -> void:
	if _ready_to_push: return
	if _dialogue_line_processing == null: return

	_ready_to_push = true
	dialogue_line_finished.emit(_dialogue_line_processing)


func _dialogue_line_process(line: DialogueLine) -> void:
	match line.dialogue_type:
		DialogueLine.DialogueType.TEXT:
			_dialogue_line_process_text(line)
		DialogueLine.DialogueType.CALLABLE:
			_dialogue_line_process_callable(line)
		DialogueLine.DialogueType.TIMER:
			_dialogue_line_process_timer(line)


func _dialogue_line_process_text(line: DialogueLine) -> void:
	var line_auto_advance: bool = line.dialogue_data.get("auto_advance")
	_add_history_line(line)

	if line_auto_advance:
		var signal_awaiter: SignalAwaiter = SignalAwaiter.new(
			dialogue_line_finished,
			func(value: DialogueLine): return value == line,
		)

		await signal_awaiter.check_out()
		get_next_line()


## 将对话行添加至历史对话行
func _add_history_line(line: DialogueLine) -> void:
	if _maximum_history_line <= 0: return
	_dialogue_line_history.append(line)

	# 若历史记录大于最大数量，则削至最大数量。
	if _dialogue_line_history.size() <= _maximum_history_line: return
	_dialogue_line_history.reverse()
	_dialogue_line_history.resize(_maximum_history_line)
	_dialogue_line_history.reverse()


func _dialogue_line_process_callable(line: DialogueLine) -> void:
	var line_callable: Callable = line.dialogue_data.get("callable")
	var line_await: bool = line.dialogue_data.get("await")
	var line_auto_advance: bool = line.dialogue_data.get("auto_advance")

	if line_callable.is_valid():
		if line_await:
			await line_callable.call()
		else:
			line_callable.call()

	_finish_line()
	if line_auto_advance: get_next_line()


func _dialogue_line_process_timer(line: DialogueLine) -> void:
	var wait_time: float = line.dialogue_data.get("wait_time")
	await _current_tree.create_timer(wait_time).timeout
	_finish_line()
	get_next_line()
