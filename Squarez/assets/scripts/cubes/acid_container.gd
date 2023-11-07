extends MeshInstance3D

@onready var buble = $buble

var life_time: float = 1
var max_count: int = 32
var _count: int = 0
var _spawn_delta: float = 0.1
var _time_delta: float = 0

func _ready():
	buble.visible = false
	pass

func _process(delta):
	_time_delta += delta
	if _time_delta > _spawn_delta:
		_time_delta -= _spawn_delta
		if _count < max_count:
			_spawn()
	pass

func _spawn():
	_count += 1
	var n := buble.duplicate()
	n.visible = true
	n.scale = Vector3.ZERO
	n.position = Vector3(0.9 * randf() - 0.5, buble.position.y, 0.9 * randf() - 0.5)
	add_child(n)
	var tween := n.create_tween()
	var _scale := 0.1 + randf() * 0.4
	tween.tween_property(n, "scale", Vector3(_scale, _scale, _scale), life_time).set_ease(Tween.EASE_OUT)
	await tween.finished
	n.queue_free()
	_count -= 1
	pass
