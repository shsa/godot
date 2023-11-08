shader_type spatial;

uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform vec2 offset;
uniform float scale = 1.0;

void vertex() {
	UV = UV * scale + offset;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo_tex.rgb;
}
