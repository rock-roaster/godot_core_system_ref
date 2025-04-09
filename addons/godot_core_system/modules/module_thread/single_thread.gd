extends RefCounted


enum TaskStatus {
	PENDING,    # 未开始
	RUNNING,    # 运行中
	COMPLETED,  # 已完成
	ERROR,      # 出错误
}

var _mutex: Mutex
var _semaphore: Semaphore

var _thread: Thread
var _thread_running: bool

var _task_index: int
var _task_can_advance: bool

var _task_pending_list: Array[Task]
var _task_running_list: Array[Task]


func _init() -> void:
	_mutex = Mutex.new()
	_semaphore = Semaphore.new()

	_thread = Thread.new()
	_thread_running = true

	_task_index = 0
	_task_can_advance = false

	_thread.start(_thread_function)


func _notification(what: int) -> void:
	if what != NOTIFICATION_PREDELETE: return
	_unload_thread()


func _unload_thread() -> void:
	_mutex.lock()
	_thread_running = false
	_mutex.unlock()
	_semaphore.post()
	_thread.wait_to_finish()


func _thread_function():
	while _thread_running:
		_semaphore.wait()

		if not _thread_running: break

		_mutex.lock()
		var next_task: Task
		if not _task_pending_list.is_empty():
			next_task = _task_pending_list.pop_front()
		_mutex.unlock()

		if next_task == null: continue

		_mutex.lock()
		_task_can_advance = true
		_task_running_list.append(next_task)
		_mutex.unlock()

		next_task.task_finished.connect(_on_task_finished, CONNECT_ONE_SHOT)
		next_task.process_task()


func _on_task_finished(task: Task) -> void:
	_mutex.lock()
	_task_running_list.erase(task)
	_mutex.unlock()


func _generate_task_id() -> String:
	_mutex.lock()
	_task_index += 1
	var counter: int = _task_index
	_mutex.unlock()
	return "%d_%d" % [Time.get_ticks_msec(), counter]


func add_task(
	task_function: Callable,
	task_callback: Callable = func(_result: Variant): pass,
	call_deferred: bool = true,
) -> void:

	var new_task: Task = Task.new(
		_generate_task_id(),
		task_function,
		task_callback,
		call_deferred,
	)

	_mutex.lock()
	var list_was_empty: bool = _task_pending_list.is_empty()
	_task_pending_list.append(new_task)
	_mutex.unlock()

	if list_was_empty && !_task_can_advance:
		_semaphore.post()


func next_step() -> void:
	if _task_pending_list.is_empty():
		_mutex.lock()
		_task_index = 0
		_task_can_advance = false
		_mutex.unlock()
		return

	_semaphore.post()


func get_index() -> int:
	_mutex.lock()
	var current_index: int = _task_index
	_mutex.unlock()
	return current_index


class Task:
	signal task_finished (task: Task)

	var id: String
	var status: TaskStatus
	var task_function: Callable
	var task_callback: Callable
	var call_deferred: bool

	func _init(
		_id: String,
		_task_function: Callable = Callable(),
		_task_callback: Callable = func(_result: Variant): pass,
		_call_deferred: bool = true,
	) -> void:

		status = TaskStatus.PENDING
		id = _id
		task_function = _task_function
		task_callback = _task_callback
		call_deferred = _call_deferred

	func process_task() -> void:
		if call_deferred:
			process_function.call_deferred(task_function, task_callback)
		else:
			process_function.call(task_function, task_callback)

	func process_function(function: Callable, callback: Callable) -> void:
		if not function.is_valid():
			print("task not valid: ", id)
			status = TaskStatus.ERROR
			task_finished.emit(self)
			return

		print("task function: ", id)
		status = TaskStatus.RUNNING
		var result: Variant = await function.call()
		status = TaskStatus.COMPLETED

		if callback.is_valid():
			await match_result_process(callback, result)

		task_finished.emit(self)

	func match_result_process(callable: Callable, argument: Variant) -> void:
		var argument_count: int = callable.get_argument_count()
		if argument_count == 0:
			await callable.call()
		else:
			await callable.call(argument)
