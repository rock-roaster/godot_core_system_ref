extends RefCounted
class_name CanvasTools


static func get_text_vertical(text: String) -> String:
	var text_result: String = ""
	for letter in text: text_result += letter + "\n"
	text_result = text_result.trim_suffix("\n")
	return text_result


static func tween_canvas_alpha(canvas: CanvasItem, alpha: float, time: float = 0.25) -> void:
	if !canvas.is_inside_tree(): return
	var tween_alpha: Tween = canvas.create_tween()
	tween_alpha.tween_property(canvas, ^"modulate:a", alpha, time)
	await tween_alpha.finished


static func tween_canvas_position(canvas: CanvasItem, pos_vec2: Vector2, time: float = 0.25) -> void:
	if !canvas.is_inside_tree(): return
	var tween_position: Tween = canvas.create_tween()
	tween_position.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_position.tween_property(canvas, ^"global_position", pos_vec2, time)
	await tween_position.finished


static func tween_canvas_scale(canvas: CanvasItem, scale_time: float, time: float = 0.25) -> void:
	if !canvas.is_inside_tree(): return
	var tween_scale: Tween = canvas.create_tween()
	tween_scale.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_scale.tween_property(canvas, ^"scale", Vector2.ONE * scale_time, time)
	await tween_scale.finished


static func get_focusable_control(node_array: Array) -> Array[Control]:
	var new_control_array: Array[Control] = node_array.filter(
		func(value: Variant) -> bool:
		return value is Control && value.focus_mode != Control.FOCUS_NONE)
	return new_control_array


static func get_focusable_children(node: Node) -> Array[Control]:
	var node_array: Array[Node] = NodeTools.get_all_children(node)
	return get_focusable_control(node_array)


static func set_mouse_focus(node_array: Array) -> void:
	for control in get_focusable_control(node_array):
		control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		control.mouse_entered.connect(control.grab_focus)


# 让焦点首尾互相连接循环
static func set_focus_loop_line_h(node_array: Array) -> void:
	var control_array: Array[Control] = get_focusable_control(node_array)
	var previous_control: Control = control_array[-1]
	for control in control_array:
		control.focus_neighbor_left = previous_control.get_path()
		previous_control.focus_neighbor_right = control.get_path()
		previous_control = control


static func set_focus_loop_line_v(node_array: Array) -> void:
	var control_array: Array[Control] = get_focusable_control(node_array)
	var previous_control: Control = control_array[-1]
	for control in control_array:
		control.focus_neighbor_top = previous_control.get_path()
		previous_control.focus_neighbor_bottom = control.get_path()
		previous_control = control


# 让焦点在同行同列首尾循环
static func set_focus_loop_hv(node_array: Array, horizontal_size: int) -> void:
	var control_array: Array[Control] = get_focusable_control(node_array)
	var vertical_size: int = floori(control_array.size() / float(horizontal_size))
	var extra_line_size: int = control_array.size() % horizontal_size

	for index in horizontal_size:
		var index_bottom: int = index + horizontal_size * (vertical_size - 1)
		if extra_line_size > index: index_bottom += horizontal_size
		control_array[index].focus_neighbor_top = control_array[index_bottom].get_path()
		control_array[index_bottom].focus_neighbor_bottom = control_array[index].get_path()

	for index in vertical_size:
		var index_left: int = index * horizontal_size
		var index_right: int = index_left + horizontal_size - 1
		control_array[index_left].focus_neighbor_left = control_array[index_right].get_path()
		control_array[index_right].focus_neighbor_right = control_array[index_left].get_path()

	if !extra_line_size: return
	var extra_index_left: int = horizontal_size * vertical_size
	var extra_index_right: int = extra_index_left + extra_line_size - 1
	control_array[extra_index_left].focus_neighbor_left = control_array[extra_index_right].get_path()
	control_array[extra_index_right].focus_neighbor_right = control_array[extra_index_left].get_path()


# 以自然的方式连接元素首尾
static func set_focus_loop_natural(node_array: Array, horizontal_size: int) -> void:
	var control_array: Array[Control] = get_focusable_control(node_array)
	var vertical_size: int = floori(control_array.size() / float(horizontal_size))
	var extra_line_size: int = control_array.size() % horizontal_size

	for index in horizontal_size:
		var index_bottom: int = index + horizontal_size * (vertical_size - 1)
		if extra_line_size > index: index_bottom += horizontal_size
		control_array[index].focus_neighbor_top = control_array[index_bottom].get_path()
		control_array[index_bottom].focus_neighbor_bottom = control_array[index].get_path()

	var previous_control: Control = control_array[-1]
	for control in control_array:
		control.focus_neighbor_left = previous_control.get_path()
		previous_control.focus_neighbor_right = control.get_path()
		previous_control = control
