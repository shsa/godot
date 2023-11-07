extends CubeBase

const ACID_PREFAB = preload("res://addons/translations_from_json/import_plugin.gd")

func _ready():
	pass

func set_highlight(value):
	$cube.set_highlight(value)

func placed():
	pass

func collapse():
	var m = board.get_matrix()
	var jobs = Jobs.new()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var pos = Vector2i(coord.x + x, coord.y + y)
			var cube = m.get_cube(pos)
			if cube == null:
				cube = ACID_PREFAB.instantiate()
				cube.position = Vector3(pos.x, position.y + 1, pos.y)
				board.add_cube(cube)
				jobs.add(cube.placed)
			pass
		pass
	await jobs.all()
	queue_free()
