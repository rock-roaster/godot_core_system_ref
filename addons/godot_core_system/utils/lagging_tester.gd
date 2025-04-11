extends TextureRect


func _init() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)


func _ready() -> void:
	set_global_position(Vector2.ZERO)
	thread_tween()


func thread_tween() -> void:
	var screen_size_x: int = ProjectSettings.get_setting(
		"display/window/size/viewport_width", 1920)
	var screen_size_y: int = ProjectSettings.get_setting(
		"display/window/size/viewport_height", 1080)

	var length_x: float = screen_size_x - size.x
	var length_y: float = screen_size_y - size.y

	var time_x: float = length_x * 0.001
	var time_y: float = length_y * 0.001

	var texture_tween: Tween = create_tween().set_loops()
	texture_tween.tween_property(self, ^"global_position:x", length_x, time_x)
	texture_tween.tween_property(self, ^"global_position:y", length_y, time_y)
	texture_tween.tween_property(self, ^"global_position:x", 0.0, time_x)
	texture_tween.tween_property(self, ^"global_position:y", 0.0, time_y)
