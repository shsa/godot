extends Node

@export var data: Data
@export var main: BoardMain
@export var active: BoardBase
@export var preview: BoardBase
@export var input: BoardInput
@export var collection_name: String
@export var cube_simple: PackedScene

func _ready():
	input.connect("click_preview", _click_preview)
	_new_preview()

func _new_preview():
	var collection = data.get_collection(collection_name)
	var figure = collection.next_figure()
	for coord in figure:
		var cube = cube_simple.instantiate()
		cube.coord = coord
		preview.add_cube(cube)
		pass
	preview.new_preview_after.emit()
	pass

func _can_apply() -> bool:
	var _main = main.get_matrix()
	for cube in active.get_cubes():
		if not main.in_board(cube):
			return false
		if _main[cube.coord.x][cube.coord.y] != null:
			return false
		pass

	for cube in active.get_cubes():
		active.remove_cube(cube)
		main.add_cube(cube)
		cube.set_highlight(false)
	return true

func _click_preview():
	if not _can_apply():
		return

	for cube in preview.get_cubes():
		preview.remove_cube(cube)
		active.add_cube(cube)
		cube.set_highlight(true)
	
	active.start_from_preview()	
	_new_preview()