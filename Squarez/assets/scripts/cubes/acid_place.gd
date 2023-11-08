extends CubeBase

func touch(cube: CubeBase) -> bool:
	enabled = false
	cube.enabled = false
	
	var jobs = Jobs.new()
	jobs.add(cube.collapse)
	jobs.add(collapse)
	await jobs.all()
	cube.post_collapse()
	post_collapse()
	return true

func collapse():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished
