extends BoardInput

@export var block: PackedScene
@export var data: Data

signal spawn_preview

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
	
	connect("active_start_move", _active_start_move)
	connect("active_move", _active_move)
	connect("active_rotate", _active_rotate)
	connect("click_preview", _click_preview)

var _start_figure_position = Vector3.ZERO

func _active_start_move():
	_start_figure_position = $Active.position

func _active_move(delta: Vector2):
	$Active.position = _start_figure_position + Vector3(delta.x, 0.0, delta.y)

var	_active_rotating = false
func _active_rotate():
	if _active_rotating: return
		
	_active_rotating = true
	var tween = $Active.create_tween()
	var rot = $Active.rotation + Vector3(0.0, -PI / 2, 0.0)
	tween.tween_property($Active, "rotation", rot, 0.5).connect("finished", _active_rotated)
	#$Active.rotate(Vector3.UP, PI / 2.0)

func _active_rotated():
	_active_rotating = false
	
func _click_preview():
	print("preview")

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

