extends Node3D

class_name CubeBase

@export var coord: Vector2i
@export var highlight: bool = false

var enabled: bool = true

func _ready():
	pass

func touch(_cube: CubeBase) -> bool:
	await get_tree().create_timer(0).timeout
	return false

func get_board() -> BoardBase:
	var parent = get_parent()
	if parent != null:
		parent = parent.get_parent()
	return parent

func remove_from_board():
	if get_parent() != null:
		get_parent().remove_child(self)

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
	queue_free()

func explode():
	queue_free()
