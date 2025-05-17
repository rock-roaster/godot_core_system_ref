extends State


## 进入状态
func _enter() -> bool:
	print("%s entered!" % name)
	return true


## 退出状态
func _exit() -> bool:
	print("%s exited!" % name)
	return true


func _handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed(&"ui_accept"):
		$"../State02".switch()
	return true
