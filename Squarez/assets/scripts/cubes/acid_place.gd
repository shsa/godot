extends CubeBase

func touch(cube: CubeBase) -> bool:
	enabled = false
	cube.enabled = false
	
	var tween := create_tween()
	var pos = get_board().to_board_position(cube)
	get_board().add_cube(cube)
	cube.position = Vector3(pos.x, 0, pos.z)
	tween.tween_property(cube, "position", position, Global.CAPTURE_TIME)
	await tween.finished
	
	var jobs = Jobs.new()
	jobs.add(cube.collapse)
	jobs.add(collapse)
	await jobs.all()
	return true
	
func collapse():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished
