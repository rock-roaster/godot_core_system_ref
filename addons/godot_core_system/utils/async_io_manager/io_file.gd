extends RefCounted
class_name IOFile


var _io_manager: AsyncIOManager


func _init() -> void:
	_io_manager = AsyncIOManager.new()


## 保存数据
func write(path: String, data: Variant) -> bool:
	var task_id: String = _io_manager.write_file_async(path, data)
	var result: Array = await _io_manager.io_completed
	return result[1] if result[0] == task_id else false


## 加载数据
func read(path: String) -> Variant:
	var task_id: String = _io_manager.read_file_async(path)
	var result: Array = await _io_manager.io_completed
	return result[2] if result[0] == task_id and result[1] else null
