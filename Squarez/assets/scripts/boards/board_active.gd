extends BoardBase

class_name BoardActive

@export var main: BoardMain
@export var preview: BoardBase
@export var input: BoardInput

var _start_figure_position = Vector3.ZERO
var _locked := false

func _ready():
	type = BoardBase.ACTIVE
	width = 3
	height = 3
	
	input.connect("active_start_move", _start_move)
	input.connect("active_end_move", _end_move)
	input.connect("active_move", _move)
	input.connect("active_rotate", _rotate)

func lock():
	_locked = true
	
func unlock():
	_locked = false

func _align():
	var x := 0.0
	var z := 0.0
	var _list = []
	_list.append_array(super.get_cubes())
	if len(_list) > 0:
		for cube in _list:
			x += cube.position.x
			z += cube.position.z
		x = round(x / len(_list))
		z = round(z / len(_list))
		var _center = Vector3(x, 0, z)
		var _pos = _pivot.to_global(_center)
		_pivot.position = Vector3(-x, 0, -z)
		_pos = get_parent().to_local(_pos)
		position = Vector3(_pos.x, position.y, _pos.z)

func add_cube(cube: CubeBase):
	#NOTIFICATION_CHILD_ORDER_CHANGED
	super.add_cube(cube)
	cube.position.x = cube.coord.x
	cube.position.y = 0
	cube.position.z = cube.coord.y

func get_cubes() -> Array:
	for cube in super.get_cubes():
		var pos = _pivot.to_global(cube.position)
		pos = main._pivot.to_local(pos)
		cube.coord = Vector2i(roundi(pos.x), roundi(pos.z))
		pass
	return super.get_cubes()
	
func preview_position() -> Vector3:
	return Vector3(1, position.y, 13.419)

func start_from_preview():
	var pos := preview_position()
	_start_figure_position = pos
	position = Vector3(preview.position.x, position.y, preview.position.z)
	rotation = Vector3.ZERO
	scale = preview.scale
	var tween = create_tween()
	tween.set_parallel()
	#tween.tween_property(self, "position", pos, 0.5)
	tween.tween_property(self, "scale", Vector3.ONE, 0.5)


func _start_move():
	if _locked: return
	_start_figure_position = position

func _calc_delta() -> Vector3:
	var tl := Vector2(1000, 1000)
	var br := Vector2(-1000, -1000)
	for cube in super.get_cubes():
		var pos = _pivot.to_global(cube.position)
		pos = main._pivot.to_local(pos)
		tl.x = min(tl.x, pos.x)
		tl.y = min(tl.y, pos.z)
		br.x = max(br.x, pos.x)
		br.y = max(br.y, pos.z)
	
	var delta := Vector3(round(position)) - position
	if br.x > main.width:
		delta.x = main.width - br.x - 1
	if tl.x < 0:
		delta.x = 0 - tl.x
	if br.y > main.height:
		delta.z = main.height - br.y - 1
	if tl.y < 0:
		delta.z = 0 - tl.y
	
	return delta

func _end_move():
	if _locked: return

	var delta := _calc_delta()
	var pos := position + delta
	var tween := create_tween()
	tween.tween_property(self, "position", pos, 0.1)
	pass

func _move(delta: Vector2):
	if _locked: return

	position = _start_figure_position + Vector3(delta.x, 0.0, delta.y)
	
	var jobs = Jobs.new()
	var m = main.get_matrix()
	for a_cube in get_cubes():
		var m_cube = m.get_cube(a_cube.coord)
		if m_cube != null:
			jobs.add(func():
				if await m_cube.touch(a_cube):
					await a_cube.touch(m_cube))
	await jobs.all()

func _rotate():
	if _locked: return
		
	_locked = true
	_align()
	var tween = create_tween()
	var rot = rotation + Vector3(0.0, -PI / 2, 0.0)
	tween.tween_property(self, "rotation", rot, 0.5)
	await tween.finished
	_locked = false
