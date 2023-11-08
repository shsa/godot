extends CubeBase

@export var color: Color = Color(0, 1, 0)

func set_highlight(value):
	$cube.set_highlight(value)

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
