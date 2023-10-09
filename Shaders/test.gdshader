shader_type spatial;

uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec2 size = vec2(1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform float dot_length : hint_range(0.0, 4.0) = 0.1;
uniform float dot_interval: hint_range(0.0, 4.0) = 0.2;
//uniform float phase;
uniform float speed = 1.0; // Controls the rotation

bool isDot(float _pos) {
	float _step = dot_length + dot_interval;
	float _delta = _pos - floor(_pos / _step) * _step;
	return _delta < dot_length;
}

void fragment() {
	vec2 uv = UV * size;
	float phase = TIME * speed;
	//float phase = speed;
	float alpha = 0.0;
	float _path = 0.0;
	float _offset = 0.0;
	float _max_offset = 0.0;
	vec3 _color = color;
	
	if (UV.x < 0.01 || UV.x > 0.99) {
		alpha = 1.0;
	}
	if (UV.y < 0.01 || UV.y > 0.99) {
		alpha = 1.0;
	}

	
	ALBEDO = _color;
	ALPHA = alpha;
}
