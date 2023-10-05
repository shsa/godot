shader_type spatial;

uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec2 size = vec2(1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform float dot_length : hint_range(0.0, 4.0) = 0.1;
uniform float dot_interval: hint_range(0.0, 4.0) = 0.2;
//uniform float phase;
uniform float speed = 1.0; // Controls the rotation

bool isDot(float border, float _pos) {
	if (border < border_width) {
		float _step = dot_length + dot_interval;
		float _delta = _pos - floor(_pos / _step) * _step;
		return _delta < dot_length;
	}
	return false;
}

void fragment() {
	vec2 uv = UV * size;
	float phase = TIME * speed;
	//float phase = speed;
	float alpha = 0.0;
	
	if (isDot(uv.y, phase + uv.x)) {
		alpha = 1.0;
	} else
	if (isDot(size.x - uv.x, phase + uv.y)) {
		alpha = 1.0;
	} else
	if (isDot(size.y - uv.y, phase - uv.x)) {
		alpha = 1.0;
	} else
	if (isDot(uv.x, phase - uv.y)) {
		alpha = 1.0;
	}
	
	ALBEDO = color;
	ALPHA = alpha;
}
