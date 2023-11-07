extends Node3D

class_name CubeBase

@export var coord: Vector2i
@export var highlight: bool = false

var board: BoardBase

func set_highlight(value):
	highlight = value

## Вызывается сразу после помещения квадрата на главную доску
func placed():
	pass

## Вызывается для активации действий на события типа взрыв и т.д.
func activate():
	pass

## Количество очков 
func get_scores() -> int:
	return 0

func collapse():
	queue_free()
