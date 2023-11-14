extends CubeBase

const ROCKET_PREFAB = preload("res://assets/prefabs/rocket.tscn")

@onready var _rocket: Rocket = $rocket
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
	var rot := rotation + _rocket.rotation
	var board = get_board()
	remove_child(_rocket)
	board.add_object(_rocket)
	_rocket.position = position
	_rocket.rotation = rot
	_rocket.start()

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished
	
func post_collapse():
	var board = get_board()
	board.update_matrix()
	var _dir: Vector3i = round(Vector3.BACK.rotated(Vector3.UP, _rocket.rotation.y))
	var new_pos = _rocket.position + Vector3(_dir * 20)
	var tween = _rocket.create_tween()
	tween.tween_property(_rocket, "position", new_pos, Global.ROCKET_SPEED * 20)
	remove_from_board()
	var jobs = Jobs.new()
	jobs.add(tween.finished)
	
	var pos: Vector2i = Vector2i(round(_rocket.position.x), round(_rocket.position.z))
	var dir: Vector2i = Vector2i(_dir.x, _dir.z)
	for i in range(0, 20):
		pos += dir
		var cube = board.get_cube(pos)
		if cube != null:
			jobs.add(func():
					await cube.get_tree().create_timer(Global.ROCKET_SPEED * i).timeout
					await cube.explode()
					cube.destroy()
					)
		pass
	
	await jobs.all()
	_rocket.destroy()
	destroy()
