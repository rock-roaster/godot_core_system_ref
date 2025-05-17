extends State

## 进入状态
func enter() -> void:
	print("%s entered!" % name)
	pass

## 退出状态
func exit() -> void:
	print("%s exited!" % name)
	pass

## 每帧更新
func process(_delta: float) -> void:
	pass

## 每物理帧更新
func physics_process(_delta: float) -> void:
	pass

## 处理输入
func input(_event: InputEvent) -> void:
	pass
