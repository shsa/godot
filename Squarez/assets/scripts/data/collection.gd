extends Node

class_name Collection

var _list = []

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

func next_figure() -> Array:
	var i = randi_range(0, len(_list) - 1)
	return _list[i]

