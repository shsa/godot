extends Node3D

class_name BoardBase

enum { MAIN, ACTIVE, PREVIEW }

@export var coord: Vector2i

const preview_size = 3
var width: int
var height: int
var type := MAIN

@onready var _pivot = $Pivot

func _hello():
	print("hello base")

func add_object(cube: CubeBase):
	cube.remove_from_board()
	_pivot.add_child(cube)

func add_cube(cube: CubeBase):
	cube.remove_from_board()
	_pivot.add_child(cube)

func get_cubes() -> Array:
	var list = []
	for i in range(_pivot.get_child_count()):
		var child = _pivot.get_child(i)
		if child is CubeBase:
			if child.enabled:
				list.append(child)
	return list
	
func clear():
	for cube in get_cubes():
		cube.queue_free()

func get_matrix() -> CubeMatrix:
	var matrix = CubeMatrix.new(width, height)
	for cube in get_cubes():
		matrix.set_cube(cube.coord, cube)
	return matrix

func in_board(pos) -> bool:
	if pos is CubeBase:
		pos = pos.coord
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x >= width or pos.y >= height:
		return false
	
	return true

func to_board_position(cube: CubeBase) -> Vector3:
	var pos = cube.to_global(Vector3.ZERO)
	return _pivot.to_local(pos)
