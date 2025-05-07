extends RefCounted
class_name SignalTools


static func safe_connect(safe_signal: Signal, safe_callable: Callable) -> void:
	safe_signal.connect(safe_callable)
	auto_disconnect(safe_signal, safe_callable)


static func safe_connect_deferred(safe_signal: Signal, safe_callable: Callable) -> void:
	safe_signal.connect(safe_callable, ConnectFlags.CONNECT_DEFERRED)
	auto_disconnect(safe_signal, safe_callable)


static func auto_disconnect(safe_signal: Signal, safe_callable: Callable) -> void:
	var signal_object: Object = safe_signal.get_object()
	if signal_object is Node:
		signal_object.tree_exited.connect(safe_disconnect.bind(safe_signal, safe_callable))

	var callable_object: Object = safe_callable.get_object()
	if callable_object is Node:
		callable_object.tree_exited.connect(safe_disconnect.bind(safe_signal, safe_callable))


static func safe_disconnect(safe_signal: Signal, safe_callable: Callable) -> void:
	if !safe_signal.is_connected(safe_callable): return
	safe_signal.disconnect(safe_callable)


static func disconnect_all_signals(node: Node) -> void:
	var signal_list: Array[Dictionary] = node.get_signal_list()
	for signal_dict in signal_list:
		var signal_name: String = signal_dict["name"]
		var connection_list: Array[Dictionary] = node.get_signal_connection_list(signal_name)
		for connection in connection_list:
			var node_signal: Signal = connection["signal"]
			var node_callable: Callable = connection["callable"]
			node_signal.disconnect(node_callable)
