extends Node3D

class_name CubeBase

#@onready var collider: CubeCollider = preload("res://assets/prefabs/cube_collider.tscn").instantiate()

@export var coord: Vector2i
@export var highlight: bool = false

var enabled: bool = true

func _ready():
	#add_child(collider)
	#collider.area_entered.connect(_collision)
	#collider.cube = self
	pass

#func _collision(area: Area3D):
#	if area is CubeCollider:
#		var board = area.cube.get_board()
#		var self_board = get_board()
#		match board.type:
#			BoardBase.MAIN:
#				if self_board.type == BoardBase.ACTIVE:
#					print("touch")
#					if not area.cube._touch(self): _touch(area.cube)

func _touch(cube: CubeBase) -> bool:
	var pos = get_board().to_board_position(cube)
	print(position, pos)
	if roundi(position.x) == roundi(pos.x) and roundi(position.z) == roundi(pos.z):
		return touch(cube)
	return false

func touch(cube: CubeBase) -> bool:
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
