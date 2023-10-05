shader_type spatial;

uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec2 size = vec2(1000.0, 1000.0);
uniform float border_width = 1.0;
uniform float dot_length = 5.0;
uniform float dot_interval = 5.0;
//uniform float phase;
uniform float speed = 10.0; // Controls the rotation

bool isDot(float _pos) {
	float _step = dot_length + dot_interval;
	float _delta = _pos - floor(_pos / _step) * _step;
	return _delta < dot_length;
}

bool isDot0(float border, float _pos) {
	if (border < border_width) {
		return isDot(_pos);
	}
	return false;
}

bool isDot1(float border, float _pos) {
	if (border <= border_width) {
		return isDot(_pos);
	}
	return false;
}

void fragment() {
	vec2 uv = UV * size;
	float phase = TIME * speed;
	//float phase = speed;
	float alpha = 0.0;
	
	if (isDot0(uv.y, phase + uv.x)) {
		alpha = 1.0;
	} else
	if (isDot1(size.x - uv.x - 0.03, phase + uv.y)) {
		alpha = 1.0;
	} else
	if (isDot1(size.y - uv.y - 0.03, phase - uv.x)) {
		alpha = 1.0;
	} else
	if (isDot0(uv.x, phase - uv.y)) {
		alpha = 1.0;
	}
	
	ALBEDO = color.rgb;
	ALPHA = alpha * color.a;
}
