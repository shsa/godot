class_name Shape

static func calc_center(shape: Array) -> Vector2i:
	var x := 0
	var y := 0
	for cube in shape:
		x += cube.coord.x
		y += cube.coord.y
	
	x = roundi(x * 1.0 / len(shape))
	y = roundi(y * 1.0 / len(shape))
	#var dx := 1 - x
	#var dy := 1 - y
	
	return Vector2i(x, y)
