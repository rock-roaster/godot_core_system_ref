# meta-name: State
# meta-description: State for State Machine.
extends State

## 进入状态
func enter() -> void:
	pass

## 退出状态
func exit() -> void:
	pass

## 每帧更新
func process(delta: float) -> void:
	pass

## 每物理帧更新
func physics_process(delta: float) -> void:
	pass

## 处理输入
func input(event: InputEvent) -> void:
	pass
