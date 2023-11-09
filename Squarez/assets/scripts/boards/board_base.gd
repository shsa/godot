extends Node3D

class_name BoardBase

enum { MAIN, ACTIVE, PREVIEW }

const preview_size = 3
var width: int
var height: int
var type := MAIN

@onready var _pivot = $Pivot

var _matrix = {}

func _hello():
	print("hello base")

func add_object(cube: CubeBase):
	cube.remove_from_board()
	_pivot.add_child(cube)

func add_cube(cube: CubeBase):
	cube.remove_from_board()
	_pivot.add_child(cube)

func remove_cube(cube: CubeBase):
	_matrix[cube.coord] = null
	_pivot.remove_child(cube)

func get_cubes() -> Array:
	var list = []
	for i in range(_pivot.get_child_count()):
		var child = _pivot.get_child(i)
		if child is CubeBase:
			if child.enabled:
				list.append(child)
	return list
	
func update_matrix():
	_matrix = {}
	for cube in get_cubes():
		_matrix[cube.coord] = cube

func get_cube(coord: Vector2i) -> CubeBase:
	if _matrix.has(coord):
		return _matrix[coord]
	return null

func clear():
	for cube in get_cubes():
		cube.queue_free()

func in_board(coord) -> bool:
	if coord is CubeBase:
		coord = coord.coord
	if coord.x < 0 or coord.y < 0:
		return false
	if coord.x >= width or coord.y >= height:
		return false
	
	return true

func to_board_position(cube: CubeBase) -> Vector3:
	var pos = cube.to_global(Vector3.ZERO)
	return _pivot.to_local(pos)
