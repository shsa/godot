extends BoardInput

@export var block: PackedScene
@export var cell: PackedScene
@export var data: Data

const board_group_name = "board"
const active_group_name = "active"
const preview_group_name = "preview"

const active_size = 3
const board_width = 10
const board_height = 14

@onready var _board = $Pivot
@onready var _active = $Pivot/Active
@onready var _active_pivot = $Pivot/Active/Pivot

signal spawn_preview

func _ready():
	var a = Test_class.new()
	a.test()
	print(data.data)
	
	for item in get_tree().get_nodes_in_group("trash"):
		item.queue_free()
	
	for x in range(10):
		for y in range(14):
			if randi_range(0, 10) < 2:
				var item = block.instantiate() as Node3D
				item.position.x = x
				item.position.z = y
				item.color = Color(0, 0, 1)
				item.highlight = false
				item.add_to_group(board_group_name)
				_board.add_child(item)

	for x in range(3):
		for y in range(3):
			var item = block.instantiate() as Node3D
			item.position.x = x - 1
			item.position.z = y - 1
			item.color = Color(0, 0, 1)
			item.highlight = true
			item.add_to_group(active_group_name)
			_active_pivot.add_child(item)
	
	spawn_preview.emit()
	
	connect("active_start_move", _active_start_move)
	connect("active_end_move", _active_end_move)
	connect("active_move", _active_move)
	connect("active_rotate", _active_rotate)
	connect("click_preview", _click_preview)

var _start_figure_position = Vector3.ZERO

func _active_start_move():
	_start_figure_position = _active.position

func _active_end_move():
	var pos = round(_active.position)
	var tween = _active.create_tween()
	tween.tween_property(_active, "position", pos, 0.1)
	pass

func _active_move(delta: Vector2):
	_active.position = _start_figure_position + Vector3(delta.x, 0.0, delta.y)

var	_active_rotating = false
func _active_rotate():
	if _active_rotating: return
		
	_active_rotating = true
	var tween = _active.create_tween()
	var rot = _active.rotation + Vector3(0.0, -PI / 2, 0.0)
	tween.tween_property(_active, "rotation", rot, 0.5).connect("finished", _active_rotated)
	#$Active.rotate(Vector3.UP, PI / 2.0)

func _active_rotated():
	_active_rotating = false

func _create_matrix(width: int, height: int):
	var matrix = []
	for x in range(width):
		matrix.append([])
		matrix[x] = []        
		for y in range(height):
			matrix[x].append([])
			matrix[x][y] = null
	return matrix

func _get_board_matrix():
	var matrix = _create_matrix(board_width, board_height)
	for item in get_tree().get_nodes_in_group(board_group_name):
		matrix[int(item.position.x)][int(item.position.z)] = item
	return matrix

func _get_active_items() -> Array:
	return get_tree().get_nodes_in_group(active_group_name)

func _get_active_item_coord(item: Node) -> Vector2i:
	return Vector2i(int(_active.position.x + item.position.x), int(_active.position.z + item.position.z))

func _click_preview():
	var _b = _get_board_matrix()
	var _can_apply = true
	for item in _get_active_items():
		var coord = _get_active_item_coord(item)
		if _b[coord.x][coord.y] != null:
			_can_apply = false
			break
		pass
	
	if _can_apply:
		for item in _get_active_items():
			var coord = _get_active_item_coord(item)
			item.position.x = coord.x
			item.position.z = coord.y
			item.remove_from_group(active_group_name)
			item.add_to_group(board_group_name)
			item.get_parent().remove_child(item)
			item.highlight = false
			item.update()
			_board.add_child(item)
			
		pass
	print("preview")
	

