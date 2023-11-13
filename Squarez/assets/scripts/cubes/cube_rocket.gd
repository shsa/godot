extends CubeBase

const ROCKET_PREFAB = preload("res://assets/prefabs/rocket.tscn")

@onready var _rocket: CubeBase = $rocket
@onready var _cube: Cube = $cube

func init():
	_rocket.init()

func set_highlight(value):
	_cube.set_highlight(value)

func get_scores() -> int:
	return 1
	

func placed():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.8, 0.8, 0.8), 0.05)
	tween.tween_property(self, "scale", Vector3.ONE, 0.05)
	await tween.finished

func collapse():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished
	
func post_collapse():
	var board = get_board()
	board.update_matrix()
	var jobs = Jobs.new()
	var rot = rotation + _rocket.rotation
	var dir = Vector3.BACK.rotated(Vector3.UP, rot.y)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var pos = Vector2i(coord.x + x, coord.y + y)
			var cube = board.get_cube(pos)
			if cube == null and board.in_board(pos):
				cube.coord = pos
				board.add_cube(cube)
				jobs.add(cube.placed)
			pass
		pass
	await jobs.all()
	queue_free()
