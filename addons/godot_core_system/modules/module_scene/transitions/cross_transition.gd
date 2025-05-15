extends BaseTransition
class_name CrossTransition

## 交叉淡化转场效果

var _transition_rect: TextureRect


func add_texture_rect() -> TextureRect:
	await RenderingServer.frame_post_draw
	var screen_image: Image = _transition_layer.get_viewport().get_texture().get_image()
	var image_texture: ImageTexture = ImageTexture.create_from_image(screen_image)

	var new_texture_rect: TextureRect = TextureRect.new()
	new_texture_rect.texture = image_texture
	new_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	new_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	_transition_layer.add_child(new_texture_rect)
	return new_texture_rect


func _process_tween(value: float, duration: float) -> void:
	var tween: Tween = _transition_rect.create_tween()
	tween.tween_property(_transition_rect, "modulate:a", value, duration)
	await tween.finished


## 执行开始转场
## @param duration 转场持续时间
func _do_start(_duration: float) -> void:
	_transition_rect = await add_texture_rect()


## 执行结束转场
## @param duration 转场持续时间
func _do_end(duration: float) -> void:
	await _process_tween(0.0, duration)
	_transition_rect.queue_free()
