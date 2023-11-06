class_name CubeMatrix

var width: int
var height: int

var _data = {}

func _init(width: int, height: int):
	self.width = width
	self.height = height

func get_cube(pos: Vector2i) -> CubeBase:
	if _data.has(pos):
		return _data[pos]
	return null

func set_cube(pos: Vector2i, cube: CubeBase):
	_data[pos] = cube

func contains(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x >= width or pos.y >= height:
		return false
	return true
