extends State


## 进入状态
func _enter() -> bool:
	print("%s entered!" % name)
	return false


## 退出状态
func _exit() -> bool:
	print("%s exited!" % name)
	return false


func _handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed(&"ui_accept"):
		$"../../State01".switch()
	return false
