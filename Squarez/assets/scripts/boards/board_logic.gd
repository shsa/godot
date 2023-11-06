extends Node

class_name BoardLogic

@export var data: Data
@export var main: BoardMain
@export var active: BoardActive
@export var preview: BoardBase
@export var input: BoardInput
@export var collection_name: String

@export var cube_error: PackedScene
@export var cube_simple: PackedScene
@export var cube_bomb: PackedScene
@export var cube_test: PackedScene

signal updated
var scores: int = 0

func _ready():
	input.connect("click_preview", _click_preview)
	_new_preview()

func _new_cube(cube_name: String) -> CubeBase:
	match cube_name:
		"bomb":
			return cube_bomb.instantiate()
		"simple":
			return cube_simple.instantiate()
		_:
			return cube_error.instantiate()
	

func _new_preview():
	var collection = data.get_collection(collection_name)
	var shape = collection.next_shape()
	for coord in shape:
		var cube = _new_cube(collection.next_cube())
		cube.coord = coord
		preview.add_cube(cube)
		pass
	preview.new_preview_after.emit()
	pass

func _can_apply() -> bool:
	var _matrix = main.get_matrix()
	var _errors = []
	for cube in active.get_cubes():
		if not _matrix.contains(cube.coord):
			_errors.append(cube)
		elif _matrix.get_cube(cube.coord) != null:
			_errors.append(cube)
		pass

	if len(_errors) == 0: return true
	
	var jobs := Jobs.new()
	for cube in _errors:
		var error = cube_error.instantiate()
		error.position = cube.position
		active._pivot.add_child(error)
		jobs.add(error.play)
		
	await jobs.all()
	return false

func _apply():
	var jobs := Jobs.new()
	for cube in active.get_cubes():
		active.remove_cube(cube)
		main.add_cube(cube)
		cube.set_highlight(false)
		jobs.add(cube.placed)
	await jobs.all()
	return true

func _apply_active():
	await _apply()
	await _find_clusters()

func _apply_preview():
	_apply_active()
		
	for cube in preview.get_cubes():
		preview.remove_cube(cube)
		active.add_cube(cube)
		cube.set_highlight(true)
	
	active.start_from_preview()
	_new_preview()

func _select_cluster(matrix: CubeMatrix, start_x: int, start_y: int) -> Array:
	var list = []
	for x in range(start_x, start_x + BoardActive.preview_size):
		for y in range(start_y, start_y + BoardActive.preview_size):
			var pos = Vector2i(x, y)
			var cube = matrix.get_cube(pos)
			if cube == null: 
				return []
			if cube.get_scores() == 0: 
				return []
			list.append(cube)
		pass
	pass
	return list

func _find_clusters():
	var list = []
	var m = main.get_matrix()
	var _hash = {}
	for x in range(m.width):
		for y in range(m.height):
			for cube in _select_cluster(m, x, y):
				if not _hash.has(cube.coord):
					_hash[cube.coord] = true
					list.append(cube)
				pass
			pass
		pass
	pass
	var jobs = Jobs.new()
	for cube in list:
		scores += cube.get_scores()
		jobs.add(cube.collapse)
	await jobs.all()
	updated.emit()

func _click_preview():
	active.lock()
	if await _can_apply():
		_apply_preview()
	active.unlock()
