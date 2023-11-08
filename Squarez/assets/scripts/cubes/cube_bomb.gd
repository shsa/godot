extends CubeBase

func activate():
	var explosion = ResourceLoader.load("res://assets/prefabs/explosion.tscn")
	var m = get_board().get_matrix()
	var jobs = Jobs.new()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var obj = explosion.instantiate()
			var pos = Vector2i(coord.x + x, coord.y + y)
			obj.position = Vector3(pos.x, position.y + 1, pos.y)
			get_board().add_object(obj)
			jobs.add(obj.play)
			var cube = m.get_cube(pos)
			if cube != null:
				jobs.add(cube.explode)
		pass
	await jobs.all()

