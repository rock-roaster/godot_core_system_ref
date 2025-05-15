extends BaseTransition
class_name DissolveTransition

## 溶解转场效果

const dissolve_shader: Shader = preload("./dissolve_shader.gdshader")

var _transition_rect: ColorRect


func _set_noise_texture() -> void:
	var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
	noise_texture.noise = FastNoiseLite.new()
	noise_texture.width = _transition_rect.size.x * 0.5
	noise_texture.height = _transition_rect.size.y * 0.5

	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = dissolve_shader
	shader_material.set_shader_parameter("dissolve_noise", noise_texture)
	shader_material.set_shader_parameter("dissolve_value", 0.0)
	#shader_material.set_shader_parameter("burn_size", 0.1)

	_transition_rect.material = shader_material


func _change_dissolve_value(value: float) -> void:
	var shader_material: ShaderMaterial = _transition_rect.material
	shader_material.set_shader_parameter("dissolve_value", value)


func _process_tween(from: float, to: float, duration: float) -> void:
	var tween: Tween = _transition_rect.create_tween()
	tween.tween_method(_change_dissolve_value, from, to, duration)
	await tween.finished


## 执行开始转场
## @param duration 转场持续时间
func _do_start(duration: float) -> void:
	_transition_rect = add_transition_rect()
	_set_noise_texture()
	await _process_tween(0.0, 1.0, duration)


## 执行结束转场
## @param duration 转场持续时间
func _do_end(duration: float) -> void:
	await _process_tween(1.0, 0.0, duration)
	_transition_rect.queue_free()
