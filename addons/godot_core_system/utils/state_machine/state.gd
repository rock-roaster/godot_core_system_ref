extends Node
class_name State


var parent_state: State
var state_machine: StateMachine


func enter() -> void:
	if _enter() && parent_state:
		parent_state.enter()


func exit() -> void:
	if _exit() && parent_state:
		parent_state.exit()


func update(delta: float) -> void:
	if _update(delta) && parent_state:
		parent_state.update(delta)


func physics_update(delta: float) -> void:
	if _physics_update(delta) && parent_state:
		parent_state.physics_update(delta)


func handle_input(event: InputEvent) -> void:
	if _handle_input(event) && parent_state:
		parent_state.handle_input(event)


func switch() -> void:
	if state_machine:
		state_machine.switch(self)


func get_sub_states() -> Array[State]:
	var state_array: Array[State] = []
	var child_array: Array = get_children().filter(
		func(value: Node) -> bool: return value is State)
	state_array.append_array(child_array)
	return state_array


func _setup_sub_states() -> void:
	for state in get_sub_states():
		state.parent_state = self
		state.state_machine = state_machine
		state._setup_sub_states()


func _enter() -> bool: return true
func _exit() -> bool: return true
func _update(delta: float) -> bool: return true
func _physics_update(delta: float) -> bool: return true
func _handle_input(event: InputEvent) -> bool: return true
