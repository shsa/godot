extends Node

class_name Collection

var _list = []
var _cubes = []

func _init(data: Dictionary):
	name = data["name"]
	for item in data["items"]:
		var coords = []
		var coord = Vector2i(-1, -1)
		for _line in item["lines"]:
			coord.y += 1
			coord.x = -1
			for _c in _line:
				coord.x += 1
				if _c != ".":
					coords.append(coord)
		for i in range(0, item["count"]):
			_list.append(coords)
			
	var d = data["cubes"]
	for cube_name in d:
		for i in range(0, d[cube_name]):
			_cubes.append(cube_name)

func next_shape() -> Array:
	var i = randi_range(0, len(_list) - 1)
	return _list[i]

func next_cube() -> String:
	var i = randi_range(0, len(_cubes) - 1)
	return _cubes[i]
