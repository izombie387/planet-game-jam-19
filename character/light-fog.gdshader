shader_type canvas_item;

uniform sampler2D noise_tex : filter_nearest;
uniform float wave_num = 5.0;
uniform float amplitude = 0.1;
uniform float speed = 0.5;

void fragment() {
	//float w = sin(UV.y * wave_num);
	//float wave = sin(TIME * speed) * w * amplitude;
	//vec2 distored_uv = vec2(UV.x + wave, UV.y + wave);
	//COLOR = texture(noise_tex, distored_uv);
	COLOR = vec4(0.0);
}