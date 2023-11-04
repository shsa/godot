extends Node3D

class_name BoardInput

@export var board_preview: BoardBase

signal active_start_move
signal active_end_move
signal active_move(delta: Vector2)
signal active_rotate
signal click_preview

var touch_pressed = false
var touch_start_time = 0.0
var touch_start_position = Vector2.ZERO
var click_delta = 0.5

var timer = 0
func _process(delta):
	timer += delta
	pass

func _screen_to_local(screen_position: Vector2) -> Vector2:
	var viewport = get_viewport()
	var camera = get_viewport().get_camera_3d()
	var world_position = camera.project_position(screen_position, 100.0)
	world_position = to_local(world_position)
	return Vector2(world_position.x, world_position.z)

func _check_touch(screen_position: Vector2, collider: Node3D):
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var origin = camera.project_ray_origin(mouse_position)
	var end = origin + camera.project_ray_normal(mouse_position) * camera.far
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(origin, end)
	params.set_collide_with_areas(true)
	var result = space_state.intersect_ray(params)
	return result.has("collider") && result["collider"] == board_preview
	

func _input(event):
	if event is InputEventMouseMotion:
		if touch_pressed:
			active_move.emit(_screen_to_local(event.position) - _screen_to_local(touch_start_position))
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				touch_pressed = true
				touch_start_time = timer
				touch_start_position = event.position
				if _check_touch(event.position, board_preview):
					click_preview.emit()
				active_start_move.emit()
		else:
			if event.button_index == 1:
				touch_pressed = false
				if (timer - touch_start_time) < click_delta:
					var move_delta = (event.position - touch_start_position).length()
					if move_delta < 1.0:
						if _check_touch(event.position, board_preview):
							click_preview.emit()
						else:
							active_rotate.emit()
				active_end_move.emit()
