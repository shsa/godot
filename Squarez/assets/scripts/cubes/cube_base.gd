extends Node3D

class_name CubeBase

@export var coord: Vector2i
@export var highlight: bool = false

var enabled: bool = true

func _ready():
	pass

func init():
	pass

func touch(_cube: CubeBase) -> bool:
	await get_tree().create_timer(0).timeout
	return false

func get_board() -> BoardBase:
	var parent = get_parent()
	if parent != null:
		parent = parent.get_parent()
	return parent

func get_dir() -> Vector3:
	var p0 = to_global(Vector3.ZERO)
	var p1 = to_global(Vector3.BACK)
	var d = p1 - p0
	return d

func remove_from_board():
	var _board = get_board()
	if _board != null:
		_board.remove_cube(self)

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
	pass

func post_collapse():
	destroy()

func explode():
	enabled = false
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, Global.COLLAPSE_TIME)
	await tween.finished
	destroy()

func destroy():
	remove_from_board()
	queue_free()
