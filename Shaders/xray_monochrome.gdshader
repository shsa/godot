shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform vec3 color: source_color = vec3(1, 0, 0);

void fragment () {
	ALBEDO = color;
}