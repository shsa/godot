extends BoardBase

class_name BoardMain

@export var cell: PackedScene
@onready var logic: BoardLogic = $Logic

func _ready():
	board_name = "main"
	width = 10
	height = 14

	for item in get_tree().get_nodes_in_group("trash"):
		item.queue_free()
	
#	for x in range(10):
#		for y in range(14):
#			if randi_range(0, 10) < 2:
#				var item = block.instantiate() as Node3D
#				item.position.x = x
#				item.position.z = y
#				item.color = Color(0, 0, 1)
#				item.highlight = false
#				item.add_to_group(board_group_name)
#				_board.add_child(item)
#
#	for x in range(3):
#		for y in range(3):
#			var item = block.instantiate() as Node3D
#			item.position.x = x - 1
#			item.position.z = y - 1
#			item.color = Color(0, 0, 1)
#			item.highlight = true
#			item.add_to_group(active_group_name)
#			_active_pivot.add_child(item)
	
#	connect("active_start_move", _active_start_move)
#	connect("active_end_move", _active_end_move)
#	connect("active_move", _active_move)
#	connect("active_rotate", _active_rotate)
#	connect("click_preview", _click_preview)

func add_cube(cube: CubeBase):
	super.add_cube(cube)
	cube.position.x = cube.coord.x
	cube.position.y = 0
	cube.position.z = cube.coord.y


func _hello():
	print("hello main")
