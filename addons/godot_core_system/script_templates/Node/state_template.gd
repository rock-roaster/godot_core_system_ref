# meta-name: State
# meta-description: State for State Machine.
extends State

## 当虚函数返回true时，执行沿节点树向上传播


## 进入状态
func _enter() -> bool:
	return true


## 退出状态
func _exit() -> bool:
	return true


## 每帧更新
func _update(delta: float) -> bool:
	return true


## 每物理帧更新
func _physics_update(delta: float) -> bool:
	return true


## 处理输入
func _handle_input(event: InputEvent) -> bool:
	return true
