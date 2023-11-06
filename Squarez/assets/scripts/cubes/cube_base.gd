extends Node3D

class_name CubeBase

@export var coord: Vector2i
@export var highlight: bool = false

var board: BoardBase

func set_highlight(value):
	highlight = value

## Вызывается сразу после помещения квадрата на главную доску
## для активации действий на размещение (взрыв и т.д.)
func placed():
	pass

func get_scores() -> int:
	return 1

func collapse():
	queue_free()
