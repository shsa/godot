shader_type spatial;

uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec2 size = vec2(1.0, 1.0);
uniform float border_width = 0.05;
uniform float dot_length = 0.1;
uniform float dot_interval = 0.2;
//uniform float phase;
uniform float speed = 1.0; // Controls the rotation

bool isDot(float _pos) {
	float _step = dot_length + dot_interval;
	float _delta = _pos - floor(_pos / _step) * _step;
	return _delta < dot_length;
}

void fragment() {
	vec2 uv = UV * size;
	//float phase = TIME * speed;
	float phase = speed;
	float alpha = 0.0;
	float _path = 0.0;
	float _offset = 0.0;
	float _max_offset = 0.0;
	vec3 _color = color;
	
	if (uv.y < border_width) {
		// top
		if (uv.x < border_width) {
			// top-left corner
			bool _top = isDot(border_width - phase);
			if (_top)
			{
				_top = isDot(uv.x - phase);
				if (_top)
				{
					alpha = 1.0;
				}
			} else {
				float _path = size.x + size.y + size.x - 3.0 * border_width;
				bool _left = isDot(_path + b(border_width - uv.y) - phase);
				if (_left) {
					alpha = 1.0;
				}
			}
		} else if ((1.0 - uv.x) < border_width) {
			// top-right cordern
			bool _top = isDot((size.x - border_width) - phase);
			if (_top) {
				if (isDot(uv.x - phase)) {
					alpha = 1.0;
				}
			} else {
				bool _right = isDot((size.x - border_width) + uv.y - phase);
				if (_right) {
					alpha = 1.0;
				}
			}
		} else {
			// top-middle
			if (isDot(uv.x - phase)) {
				alpha = 1.0;
				_color = vec3(0.0, 1.0, 0.0);
			}
		}
	} else if ((size.x - uv.x) < border_width) {
		// right
		float _path = size.x - border_width;
		if ((1.0 - uv.y) < border_width) {
			// right-bottom cordern
			
			bool _right = isDot(_path + (size.y - border_width) - phase);
			if (_right) {
				bool _bottom = isDot(_path + uv.y - phase);
				if (_bottom) {
					alpha = 1.0;
				}
			} else {
				_right = isDot(_path + (size.y - border_width) + (1.0 - uv.x) - phase);
				if (_right) {
					alpha = 1.0;
				}
			}
		} else {
			// right-middle
			if (isDot(_path + uv.y - phase)) {
				alpha = 1.0;
			}
		}
	} else if ((size.y - uv.y) < border_width) {
		// bottom
		float _path = size.x + size.y + size.x - 2.0 * border_width;
		if (uv.x < border_width) {
			// bottom-left cordern
			if (isDot(_path - border_width - phase)) {
				if (isDot(_path - uv.x - phase)) {
					alpha = 1.0;
				}
			} else {
				if (isDot(_path + (1.0 - uv.y) - border_width - phase)) {
					alpha = 1.0;
				}
			}
		} else {
			// right-middle
			if (isDot(_path - uv.x - phase)) {
				alpha = 1.0;
			}
		}
	} else if (uv.x < border_width) {
		// left-middle
		float _path = size.x + size.y + size.x - 3.0 * border_width;
		if (isDot(_path + (1.0 - uv.y) - phase)) {
			alpha = 1.0;
		}
	} else {
		alpha = 0.0;
	}

	
	ALBEDO = _color;
	ALPHA = alpha;
}
