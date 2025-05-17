extends Node


@onready var state_machine: StateMachine = $StateMachine


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"): state_machine.switch($StateMachine/State01)
	if event.is_action_pressed(&"ui_right"): state_machine.switch($StateMachine/State02)
	if event.is_action_pressed(&"ui_up"): state_machine.switch($StateMachine/State03)
