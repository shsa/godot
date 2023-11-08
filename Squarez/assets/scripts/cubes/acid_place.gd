extends CubeBase

@onready var _container: AcidContainer = $container

func touch(cube: CubeBase) -> bool:
	enabled = false
	cube.enabled = false
	
	var pos = get_board().to_board_position(cube)
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
