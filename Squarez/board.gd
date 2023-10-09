extends Node3D

@export var block: PackedScene
@export var data: Data

signal spawn_preview
signal start_move_figure
signal move_figure(delta: Vector2)
signal rotate_figure

func _ready():
	var a = Test_class.new()
	a.test()
	print(data.data)
	
#	for x in range(10):
#		for y in range(10):
#			var item = block.instantiate() as Node3D
#			item.position.x = x
#			item.position.z = y
#			item.color = Color(0, 0, 1)
#			$Pivot.add_child(item)

	for x in range(3):
		for y in range(3):
			var item = block.instantiate() as Node3D
			item.position.x = x
			item.position.z = y
			item.color = Color(0, 0, 1)
			$Active/Pivot.add_child(item)
	
	spawn_preview.emit()
	
	connect("start_move_figure", _start_move_figure)
	connect("move_figure", _move_figure)
	connect("rotate_figure", _rotate_figure)

var _start_figure_position = Vector3.ZERO

func _start_move_figure():
	_start_figure_position = $Active.position

func _move_figure(delta: Vector2):
	$Active.position = _start_figure_position + Vector3(delta.x, 0.0, delta.y)
	
func _rotate_figure():
	var tween = $Active.create_tween()
	var rot = $Active.rotation + Vector3(0.0, -PI / 2, 0.0)
	tween.tween_property($Active, "rotation", rot, 1.0).connect("finished", _figure_rotated)
	#$Active.rotate(Vector3.UP, PI / 2.0)

func _figure_rotated():
	print("ok")
	pass


var timer = 0
func _process(delta):
	timer += delta
	pass

var touch_pressed = false
var touch_start_time = 0.0
var touch_start_position = Vector2.ZERO
var click_delta = 0.5

func _screen_to_board(screen_position: Vector2) -> Vector2:
	var viewport = get_viewport()
	var camera = get_viewport().get_camera_3d()
	var world_position = camera.project_position(screen_position, 100.0)
	world_position = to_local(world_position)
	return Vector2(world_position.x, world_position.z)

func _input(event):
	if event is InputEventMouseMotion:
		if touch_pressed:
			move_figure.emit(_screen_to_board(event.position) - _screen_to_board(touch_start_position))
			#move_figure.emit(_screen_to_board(event.position))
	if event is InputEventMouseButton:
		if event.pressed:
			touch_start_time = timer
			touch_start_position = event.position
			touch_pressed = true
			start_move_figure.emit()
		else:
			touch_pressed = false
			if (timer - touch_start_time) < click_delta:
				var move_delta = (event.position - touch_start_position).length()
				if move_delta < 1.0:
					rotate_figure.emit()
		
#		var viewport = get_viewport()
#		var mouse_position = viewport.get_mouse_position()
#		var camera = get_viewport().get_camera_3d()
#		var origin = camera.project_ray_origin(mouse_position)
#		var end = origin + camera.project_ray_normal(mouse_position) * camera.far
#		print(origin, end)
#		var space_state = get_world_3d().direct_space_state
#		var p = PhysicsRayQueryParameters3D.create(origin, end)
#		p.set_collide_with_areas(true)
#		var result = space_state.intersect_ray(p)
#		for key in result:
#			var item = result[key]
#			print(key, item)
#		print(result)

