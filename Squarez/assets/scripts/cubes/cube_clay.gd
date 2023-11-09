extends CubeBase

const CLAY_PREFAB = preload("res://assets/prefabs/cubes/clay_place.tscn")

func set_highlight(value):
	$cube.set_highlight(value)

func placed():
	pass

func collapse():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished

func post_collapse():
	var board = get_board()
	board.update_matrix()
	var jobs = Jobs.new()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var pos = Vector2i(coord.x + x, coord.y + y)
			var cube = board.get_cube(pos)
			if cube == null and board.in_board(pos):
				cube = CLAY_PREFAB.instantiate()
				cube.coord = pos
				board.add_cube(cube)
				jobs.add(cube.placed)
			pass
		pass
	await jobs.all()
	queue_free()

func get_scores() -> int:
	return 1
