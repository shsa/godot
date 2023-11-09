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
@export var cube_acid: PackedScene
@export var cube_test: PackedScene

signal updated
var scores: int = 0

var _cubePrefabs = {}

func _cube_prefab(cube_name: String) -> PackedScene:
	if _cubePrefabs.has(cube_name):
		return _cubePrefabs[cube_name]
	
	var path = "res://assets/prefabs/cubes/cube_" + cube_name + ".tscn"
	var prefab: PackedScene = null
	if ResourceLoader.exists(path):
		prefab = ResourceLoader.load(path)
	_cubePrefabs[cube_name] = prefab
	
	return prefab
	
func _ready():
	input.connect("click_preview", _click_preview)
	
	_new_preview()

func _new_cube(cube_name: String) -> CubeBase:
	var prefab = _cube_prefab(cube_name)
	if prefab == null:
		prefab = _cube_prefab("error")
	return prefab.instantiate()

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
	var _errors = []
	for cube in active.get_cubes():
		if not main.in_board(cube.coord):
			_errors.append(cube)
		elif main.get_cube(cube.coord) != null:
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
		cube.remove_from_board()
		main.add_cube(cube)
		jobs.add(cube.placed)
	await jobs.all()
	return true

func _select_cluster(start_x: int, start_y: int) -> Array:
	var list = []
	for x in range(start_x, start_x + BoardActive.preview_size):
		for y in range(start_y, start_y + BoardActive.preview_size):
			var pos = Vector2i(x, y)
			var cube = main.get_cube(pos)
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
	var _hash = {}
	for x in range(main.width):
		for y in range(main.height):
			for cube in _select_cluster(x, y):
				if not _hash.has(cube.coord):
					_hash[cube.coord] = true
					list.append(cube)
				pass
			pass
		pass
	return list

func _collapse_clusters(clusters: Array):
	var jobs = Jobs.new()
	for cube in clusters:
		cube.enabled = false
		scores += cube.get_scores()
		jobs.add(cube.collapse)
	await jobs.all()

	jobs = Jobs.new()
	for cube in clusters:
		jobs.add(cube.post_collapse)
	await jobs.all()
	
	updated.emit()

func _activate_cubes():
	var jobs = Jobs.new()
	for cube in main.get_cubes():
		jobs.add(cube.activate)
	await jobs.all()

func _apply_active():
	await _apply()
	main.update_matrix()
	var clusters = _find_clusters()
	await _collapse_clusters(clusters)
	main.update_matrix()
	await _activate_cubes()

func _apply_preview():
	_apply_active()
		
	for cube in preview.get_cubes():
		cube.remove_from_board()
		active.add_cube(cube)
	
	active.start_from_preview()
	_new_preview()

func _click_preview():
	active.lock()
	main.update_matrix()
	if await _can_apply():
		_apply_preview()
	active.unlock()
