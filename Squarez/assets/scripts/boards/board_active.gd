extends BoardBase

@export var main: BoardMain
@export var preview: BoardBase
@export var input: BoardInput

var _start_figure_position = Vector3.ZERO

func _ready():
	board_name = "Active"
	width = 3
	height = 3
	
	input.connect("active_start_move", _start_move)
	input.connect("active_end_move", _end_move)
	input.connect("active_move", _move)
	input.connect("active_rotate", _rotate)

func add_cube(cube: CubeBase):
	super.add_cube(cube)
	cube.position.x = cube.coord.x - 1
	cube.position.y = 0
	cube.position.z = cube.coord.y - 1

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
	var pos = preview_position()
	position = Vector3(preview.position.x, position.y, preview.position.z)
	rotation = Vector3.ZERO
	scale = preview.scale
	var tween = create_tween()
	tween.set_parallel()
	#tween.tween_property(self, "position", pos, 0.5)
	tween.tween_property(self, "scale", Vector3.ONE, 0.5)


func _start_move():
	_start_figure_position = position

func _calc_bounds() -> Rect2:
	var tl := Vector2(1000, 1000)
	var br := Vector2(-1000, -1000)
	for cube in super.get_cubes():
		var pos = _pivot.to_global(cube.position)
		pos = main._pivot.to_local(pos)
		tl.x = min(tl.x, pos.x)
		tl.y = min(tl.y, pos.z)
		br.x = max(br.x, pos.x)
		br.y = max(br.y, pos.z)
	print(tl, br)
	return Rect2(tl, br - tl + Vector2.ONE)

func _end_move():
	var bounds := _calc_bounds()
	var delta := Vector3(round(position)) - position
	if (bounds.position.x + bounds.size.x) > main.width:
		delta.x = main.width - (bounds.position.x + bounds.size.x)
	if bounds.position.x < 0:
		delta.x = -bounds.position.x
	if (bounds.position.y + bounds.size.y) > main.height:
		delta.z = main.height - (bounds.position.y + bounds.size.y)
	if bounds.position.y < 0:
		delta.z = -bounds.position.y
	
	var pos := position + delta
	print(bounds, delta, pos)
	var tween := create_tween()
	tween.tween_property(self, "position", pos, 0.1)
	pass

func _move(delta: Vector2):
	position = _start_figure_position + Vector3(delta.x, 0.0, delta.y)

var	_rotating = false
func _rotate():
	if _rotating: return
		
	_rotating = true
	var tween = create_tween()
	var rot = rotation + Vector3(0.0, -PI / 2, 0.0)
	tween.tween_property(self, "rotation", rot, 0.5)
	await tween.finished
	_rotating = false
