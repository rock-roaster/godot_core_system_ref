extends Node
class_name StateMachine


@export var current_state: State = null


func _ready() -> void:
	for state in get_children_states():
		state.state_machine = self

	if current_state:
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.input(event)


func switch(state: State) -> void:
	if current_state == state: return
	if current_state:
		current_state.exit()
	current_state = state
	current_state.enter()


func get_child_state(id: String) -> State:
	for state in get_children_states():
		if state.name == id: return state
	return null


func get_children_states() -> Array[State]:
	var node_array: Array = get_children().filter(
		func(value: Node) -> bool: return value is State)
	var state_array: Array[State] = []
	state_array.append_array(node_array)
	return state_array
