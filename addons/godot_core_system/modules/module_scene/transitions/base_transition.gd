extends Resource
class_name BaseTransition

## 转场效果基类
## 所有自定义转场效果都应该继承这个类

## 转场层
var _transition_layer: CanvasLayer


## 初始化转场效果
## @param transition_layer 转场图层
func init(
	transition_layer: CanvasLayer,
	) -> void:
	_transition_layer = transition_layer


func add_transition_rect() -> ColorRect:
	var new_rect: ColorRect = ColorRect.new()
	new_rect.color = Color.BLACK
	new_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	_transition_layer.add_child(new_rect)
	return new_rect


## 开始转场效果
## @param duration 转场持续时间
func start(duration: float) -> void:
	if not _transition_layer:
		return
	_reset_state()
	await _do_start(duration)


## 结束转场效果
## @param duration 转场持续时间
func end(duration: float) -> void:
	if not _transition_layer:
		return
	await _do_end(duration)
	_reset_state()


## 重置状态
## 在开始和结束转场时都会调用
func _reset_state() -> void:
	if not _transition_layer:
		return


## 执行开始转场
## 子类必须实现这个方法
## @param duration 转场持续时间
func _do_start(_duration: float) -> void:
	push_error("BaseTransition._do_start() not implemented!")


## 执行结束转场
## 子类必须实现这个方法
## @param duration 转场持续时间
func _do_end(_duration: float) -> void:
	push_error("BaseTransition._do_end() not implemented!")


## 清理资源
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_transition_layer = null
