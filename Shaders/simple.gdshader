shader_type spatial;

render_mode depth_draw_always;

uniform vec4 color: source_color;

void fragment() {
	ALBEDO.rgb = color.rgb;
	ALPHA = color.a;
}
