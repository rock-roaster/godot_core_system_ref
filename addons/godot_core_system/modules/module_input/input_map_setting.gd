extends RefCounted


static func apply_input_map() -> void:
	var input_map: Dictionary[String, Array] = get_input_map()
	for action in input_map:
		if InputMap.has_action(action):
			InputMap.erase_action(action)

		InputMap.add_action(action)
		for event in input_map[action]:
			InputMap.action_add_event(action, event)


static func get_input_map() -> Dictionary[String, Array]:
	var input_map: Dictionary[String, Array] = {}

	#region 内置动作
	input_map["ui_accept"] = [
		key(KEY_ENTER),
		key(KEY_KP_ENTER),
		key(KEY_SPACE),
		key_physical(KEY_Z),
		key_physical(KEY_KP_5),
		mouse_button(MOUSE_BUTTON_LEFT),
		joypad_button(JOY_BUTTON_A),
	]
	input_map["ui_select"] = []
	input_map["ui_cancel"] = [
		key(KEY_ESCAPE),
		key(KEY_BACKSPACE),
		key_physical(KEY_X),
		key_physical(KEY_KP_0),
		mouse_button(MOUSE_BUTTON_RIGHT),
		joypad_button(JOY_BUTTON_B),
	]
	input_map["ui_focus_next"] = []
	input_map["ui_focus_prev"] = []
	input_map["ui_left"] = [
		key(KEY_LEFT),
		key_physical(KEY_KP_4),
		joypad_button(JOY_BUTTON_DPAD_LEFT),
	]
	input_map["ui_right"] = [
		key(KEY_RIGHT),
		key_physical(KEY_KP_6),
		joypad_button(JOY_BUTTON_DPAD_RIGHT),
	]
	input_map["ui_up"] = [
		key(KEY_UP),
		key_physical(KEY_KP_8),
		joypad_button(JOY_BUTTON_DPAD_UP),
	]
	input_map["ui_down"] = [
		key(KEY_DOWN),
		key_physical(KEY_KP_2),
		joypad_button(JOY_BUTTON_DPAD_DOWN),
	]
	#endregion

	#region 自定义动作
	input_map["ui_prev"] = [
		key_physical(KEY_Q),
		key_physical(KEY_KP_7),
		joypad_button(JOY_BUTTON_LEFT_SHOULDER),
	]
	input_map["ui_next"] = [
		key_physical(KEY_W),
		key_physical(KEY_KP_9),
		joypad_button(JOY_BUTTON_RIGHT_SHOULDER),
	]
	input_map["mode_auto"] = [
		key(KEY_SHIFT),
		key_physical(KEY_A),
		key_physical(KEY_KP_1),
		joypad_button(JOY_BUTTON_X),
	]
	input_map["mode_skip"] = [
		key(KEY_CTRL),
		key_physical(KEY_S),
		key_physical(KEY_KP_3),
		joypad_button(JOY_BUTTON_Y),
	]
	input_map["game_menu"] = [
		key(KEY_ESCAPE),
		key_physical(KEY_P),
		key_physical(KEY_KP_ADD),
		mouse_button(MOUSE_BUTTON_RIGHT),
		joypad_button(JOY_BUTTON_START),
	]
	input_map["game_back"] = [
		key(KEY_TAB),
		key_physical(KEY_O),
		key_physical(KEY_KP_PERIOD),
		joypad_button(JOY_BUTTON_BACK),
	]
	input_map["move_left"] = [
		key_physical(KEY_A),
		joypad_motion(JOY_AXIS_LEFT_X, -1.0),
	]
	input_map["move_right"] = [
		key_physical(KEY_D),
		joypad_motion(JOY_AXIS_LEFT_X, +1.0),
	]
	input_map["move_up"] = [
		key_physical(KEY_W),
		joypad_motion(JOY_AXIS_LEFT_Y, -1.0),
	]
	input_map["move_down"] = [
		key_physical(KEY_S),
		joypad_motion(JOY_AXIS_LEFT_Y, +1.0),
	]
	#endregion

	return input_map


#region 获得输入事件
# 使用例：key(KEY_C, ["CTRL"]) -> Ctrl + C
static func key(key: Key, modifier: Array = []) -> InputEventKey:
	var new_input_event: InputEventKey = InputEventKey.new()
	new_input_event.keycode = key
	new_input_event = add_modifiers(new_input_event, modifier)
	return new_input_event


# 使用例：key_physical(KEY_V, [KEY_CTRL]) -> Ctrl + V
static func key_physical(key: Key, modifier: Array = []) -> InputEventKey:
	var new_input_event: InputEventKey = InputEventKey.new()
	new_input_event.physical_keycode = key
	new_input_event = add_modifiers(new_input_event, modifier)
	return new_input_event


static func key_unicode(unicode: int, modifier: Array = []) -> InputEventKey:
	var new_input_event: InputEventKey = InputEventKey.new()
	new_input_event.unicode = unicode
	new_input_event = add_modifiers(new_input_event, modifier)
	return new_input_event


static func add_modifiers(input_event: InputEventKey, modifier: Array) -> InputEventKey:
	if modifier.is_empty():
		return input_event
	modifier = modifier.map(
		func(value: Variant) -> Variant:
		if typeof(value) in [TYPE_STRING, TYPE_STRING_NAME]:
			value = value.to_lower()
		return value
	)
	input_event.alt_pressed = modifier.has("alt") or modifier.has(KEY_ALT)
	input_event.ctrl_pressed = modifier.has("ctrl") or modifier.has(KEY_CTRL)
	input_event.meta_pressed = modifier.has("meta") or modifier.has(KEY_META)
	input_event.shift_pressed = modifier.has("shift") or modifier.has(KEY_SHIFT)
	return input_event


static func mouse_button(mouse_button: MouseButton) -> InputEventMouseButton:
	var new_input_event: InputEventMouseButton = InputEventMouseButton.new()
	new_input_event.button_index = mouse_button
	return new_input_event


static func joypad_button(joy_button: JoyButton) -> InputEventJoypadButton:
	var new_input_event: InputEventJoypadButton = InputEventJoypadButton.new()
	new_input_event.button_index = joy_button
	return new_input_event


static func joypad_motion(joy_axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var new_input_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	new_input_event.axis = joy_axis
	new_input_event.axis_value = value
	return new_input_event
#endregion
