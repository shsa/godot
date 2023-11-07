extends Node3D

class_name BoardBase

@export var coord: Vector2i

const preview_size = 3
var board_name: String
var width: int
var height: int

@onready var _pivot = $Pivot

func _hello():
	print("hello base")

func add_object(cube: CubeBase):
	_pivot.add_child(cube)
	cube.board = self

func add_cube(cube: CubeBase):
	_pivot.add_child(cube)
	cube.add_to_group(board_name)
	cube.board = self

func remove_cube(cube: CubeBase):
	cube.remove_from_group(board_name)
	cube.get_parent().remove_child(cube)

## Оставляет Cube на доске, но исключает его из кубов
func ignore_cube(cube: CubeBase):
	cube.remove_from_group(board_name)

func get_cubes() -> Array:
	return get_tree().get_nodes_in_group(board_name)
	
func clear():
	for cube in get_cubes():
		cube.queue_free()

func get_matrix() -> CubeMatrix:
	var matrix = CubeMatrix.new(width, height)
	for cube in get_cubes():
		matrix.set_cube(cube.coord, cube)
	return matrix

func in_board(cube: CubeBase) -> bool:
	if cube.coord.x < 0 or cube.coord.y < 0:
		return false
	if cube.coord.x >= width or cube.coord.y >= height:
		return false
		
	return true
