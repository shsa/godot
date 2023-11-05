extends Node3D

class_name CubeBase

@export var coord: Vector2i

func set_highlight(value):
	pass

## Вызывается сразу после помещения квадрата на главную доску
## для активации действий на размещение (взрыв и т.д.)
func placed():
	pass
