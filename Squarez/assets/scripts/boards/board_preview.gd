extends BoardBase

@export var main: BoardMain
@export var input: BoardInput
signal new_preview_after

func _ready():
	board_name = "Preview"
	width = 3
	height = 3
	
	connect("new_preview_after", _new_preview_after)

func add_cube(cube: CubeBase):
	super.add_cube(cube)
	cube.position.x = cube.coord.x
	cube.position.y = 0
	cube.position.z = cube.coord.y

func _new_preview_after():
	var pos = _pivot.position
	for cube in get_cubes():
		var scale = cube.scale
		cube.scale = Vector3.ZERO
		var tween = cube.create_tween()
		tween.tween_property(cube, "scale", scale, 0.5)
#	_pivot.position.y = -0.5
#	var tween = _pivot.create_tween()
#	tween.tween_property(_pivot, "position", pos, 3)