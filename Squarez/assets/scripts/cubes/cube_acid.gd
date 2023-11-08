extends CubeBase

const ACID_PREFAB = preload("res://assets/prefabs/cubes/acid_place.tscn")

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
	var m = board.get_matrix()
	var jobs = Jobs.new()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var pos = Vector2i(coord.x + x, coord.y + y)
			var cube = m.get_cube(pos)
			if cube == null and board.in_board(pos):
				cube = ACID_PREFAB.instantiate()
				cube.coord = pos
				board.add_cube(cube)
				jobs.add(cube.placed)
			pass
		pass
	await jobs.all()
	queue_free()

func get_scores() -> int:
	return 1
