extends BaseTransition
class_name FadeTransition

## 淡入淡出转场效果

var _transition_rect: ColorRect


func _process_tween(value: float, duration: float) -> void:
	var tween: Tween = _transition_rect.create_tween()
	tween.tween_property(_transition_rect, "color:a", value, duration)
	await tween.finished


## 执行开始转场
## @param duration 转场持续时间
func _do_start(duration: float) -> void:
	_transition_rect = add_transition_rect()
	_transition_rect.color.a = 0.0
	await _process_tween(1.0, duration)


## 执行结束转场
## @param duration 转场持续时间
func _do_end(duration: float) -> void:
	await _process_tween(0.0, duration)
	_transition_rect.queue_free()
