extends RefCounted
class_name NodeTools


static func set_unique_node(node: Node, node_name: String) -> void:
	node.set_name(node_name)
	node.set_unique_name_in_owner(true)


static func get_unique_node(node: Node, node_name: String) -> Node:
	var unique_name: String = "%" + node_name
	if not node.has_node(unique_name): return null
	return node.get_node(unique_name)


static func get_all_children(node: Node) -> Array[Node]:
	var node_array: Array[Node]
	var node_children: Array[Node] = node.get_children()
	for child in node_children:
		node_array.append(child)
		node_array.append_array(get_all_children(child))
	return node_array


static func is_node_valid(node: Variant) -> bool:
	if not is_instance_valid(node): return false
	return node is Node


static func safe_queue_free(node: Variant) -> void:
	if not is_node_valid(node): return
	node = node as Node
	if node.is_inside_tree():
		node.get_parent().remove_child(node)
	node.queue_free()


static func set_node_enable(node: Variant, value: bool) -> void:
	if not is_node_valid(node): return
	node = node as Node
	node.set_physics_process(value)
	node.set_process(value)
	node.set_process_input(value)
	node.set_process_shortcut_input(value)
	node.set_process_unhandled_input(value)
	node.set_process_unhandled_key_input(value)


static func add_child_node(child: Node, parent: CanvasItem, hide_parent: bool = true) -> void:
	var previous_focus: Control = parent.get_viewport().gui_get_focus_owner()
	if hide_parent: parent.hide()
	parent.add_sibling(child)
	await child.tree_exited
	if hide_parent: show_canvas_item(parent)
	if previous_focus != null: grab_focusable_focus(previous_focus)


static func show_canvas_item(canvas: CanvasItem) -> void:
	if canvas.is_inside_tree(): canvas.show()


static func grab_focusable_focus(focus: Control) -> void:
	if is_instance_valid(focus)\
	&& focus.is_visible_in_tree()\
	&& focus.focus_mode != Control.FOCUS_NONE:
		focus.grab_focus.call_deferred()
