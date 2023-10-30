shader_type spatial;

uniform float strength = 0;

void fragment() {
	ALBEDO = vec3(1, 1, 1);
	ALPHA = strength;
}
