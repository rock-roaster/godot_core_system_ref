shader_type canvas_item;

uniform sampler2D dissolve_noise: source_color;
uniform float dissolve_value: hint_range(0.0, 1.0) = 0.0;
uniform float burn_size: hint_range(0.0, 1.0, 0.01);

void fragment(){
    vec4 main_texture = vec4(vec3(0.0), 1.0);
	vec4 burn_color = vec4(0.0);
    vec4 noise_texture = texture(dissolve_noise, UV);

	float burn_size_step = burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);
	float threshold = smoothstep(noise_texture.x - burn_size_step, noise_texture.x, dissolve_value);

	COLOR.a *= threshold;
	COLOR.rgb = mix(burn_color.rgb, main_texture.rgb, border);
}