// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform vec3 border_size;
//uniform float phase;
uniform float speed = 1.0; // Controls the rotation


void vertex() {
	UV = UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void applyColor(vec2 base_uv) {
	
}
void fragment() {
	vec2 base_uv = UV;
	float cx = UV.x - 0.5;
	float cy = UV.y - 0.5;

	bool empty = true;
	if (UV.x < border_size.z || (1.0 - UV.x) < border_size.z || UV.y < border_size.z || (1.0 - UV.y) < border_size.z)
	{
		// uv.x = uv.x * cos(45) - uv.y * sin(45);
		float rx = cx * 0.707106781 - cy * 0.707106781;
		// uv.y = uv.x * sin(45) + uv.y * cos(45);
		float ry = cx * 0.707106781 + cy * 0.707106781;

		float phase = TIME * speed;
		if (rx > 0.0) {
			if (ry > 0.0) {
				// right
				base_uv.y = (1.0 - base_uv.x) / border_size.z;
				base_uv.x = phase 
					+ border_size.x - border_size.z * border_size.x// top
					+ UV.y * border_size.y - border_size.z * border_size.y; // right
			} else {
				// top
				base_uv.y = base_uv.y / border_size.z;
				base_uv.x = phase 
					+ base_uv.x * border_size.x; // top
			}
		} else {
	 		if (ry > 0.0) {
				// bottom
				base_uv.y = (1.0 - base_uv.y) / border_size.z;
				base_uv.x = border_size.x - border_size.x * border_size.z// top
					+ border_size.y - border_size.z * border_size.y // right
					+ base_uv.x * border_size.x - border_size.x * border_size.z // bottom
					- phase;
			} else {
				// left
				base_uv.y = base_uv.x / border_size.z;
				base_uv.x = border_size.x - border_size.x * border_size.z// top
					+ border_size.y - border_size.z * border_size.y // right
					+ border_size.x - border_size.x * border_size.z // bottom
					+ UV.y * border_size.y - border_size.z * border_size.y // left
					- phase;
			}
		}
		
		base_uv = UV;
		if (UV.y < border_size.z) {
			// top
			if (UV.x < (1.0 - border_size.z)) {
				base_uv.y = base_uv.y / border_size.z;
				base_uv.x = phase + UV.x * border_size.x;
			}
		}
		if ((1.0 - UV.y) < border_size.z) {
			// bottom
			if (UV.x > border_size.z) {
				base_uv.y = (1.0 - base_uv.y) / border_size.z;
				base_uv.x = phase - UV.x * border_size.x;
			}
		}
		if (UV.x < border_size.z) {
			// left
			if (UV.y > border_size.z) {
				base_uv.y = UV.x / border_size.z;
				base_uv.x = phase - UV.y * border_size.y;
			}
		}
		if ((1.0 - UV.x) < border_size.z) {
			// right
			if ((1.0 - UV.y) > border_size.z) {
				base_uv.y = UV.x / border_size.z;
				base_uv.x = phase + UV.y * border_size.y;
			}
		}
		
		empty = false;
	}
	
	if (empty) {
		ALPHA = 0.0f;
	} else {
		vec4 albedo_tex = texture(texture_albedo,base_uv);
		ALBEDO = albedo.rgb * albedo_tex.rgb;
		float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
		METALLIC = metallic_tex * metallic;
		vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
		float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
		ROUGHNESS = roughness_tex * roughness;
		SPECULAR = specular;

		ALPHA *= albedo.a * albedo_tex.a;
	}
}
