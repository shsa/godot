extends MeshInstance3D

class_name AcidContainer

@onready var buble = $buble

@export var life_time: float = 5
@export var max_count: int = 8
@export var max_scale: float = 0.4

var _queue = []

func _ready():
	buble.visible = false
	var _delta: float = life_time / max_count
	var _time: float = 0
	var _list = []
	for i in range(max_count):
		_list.append(_time)
		_time += _delta
	_list.shuffle()
	for f in _list:
		_spawn(f)
	pass

func _process(delta):
	if len(_queue) > 0:
		_spawn(0)
	pass

func _spawn(delta: float):
	if len(_queue) == 0:
		var t = buble.duplicate()
		add_child(t)
		_queue.push_back(t)
	var n = _queue.pop_front()
	n.visible = true
	n.scale = Vector3.ZERO
	n.position = Vector3(0.9 * randf() - 0.5, buble.position.y, 0.9 * randf() - 0.5)
	var tween := create_tween()
	var _scale := 0.1 + randf() * max_scale
	var _time = life_time / 6
	tween.tween_property(n, "scale", Vector3(_scale, _scale, _scale), _time * 5).set_ease(Tween.EASE_OUT)
	tween.tween_property(n, "scale", Vector3.ZERO, _time * 1).set_ease(Tween.EASE_IN)
	tween.custom_step(delta)
	await tween.finished
	_queue.push_back(n)
	pass
