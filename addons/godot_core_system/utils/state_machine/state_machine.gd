extends Node
class_name StateMachine


@export var current_state: State


func _ready() -> void:
	for state in get_states():
		state.state_machine = self
		state._setup_sub_states()

	if current_state:
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func switch(state: State) -> void:
	if current_state == state: return
	if current_state:
		current_state.exit()
	current_state = state
	if current_state:
		current_state.enter()


func get_states() -> Array[State]:
	var state_array: Array[State] = []
	var child_array: Array = get_children().filter(
		func(value: Node) -> bool: return value is State)
	state_array.append_array(child_array)
	return state_array
