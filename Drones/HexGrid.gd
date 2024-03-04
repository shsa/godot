extends Node3D

var LineDrawer = preload("res://DrawLine3D.gd").new()

#https://habr.com/ru/articles/557496/
const size = 5.0
var short = size*sqrt(3)/2 # половина короткой диагонали
var long = size/2 # четверть длинной диагонали

var grid_basis = Transform2D() # матрица базиса вспомогательной сетки
var hex_basis = Transform2D() # матрица базиса гексагональной сетки

var selected_cell = Vector2.ZERO

func _ready():
	add_child(LineDrawer)

	# Для вертикальной сетки
	grid_basis.x = Vector2(long, 0)
	grid_basis.y = Vector2(0, short)

	hex_basis.x = grid_basis.x*3 + grid_basis.y
	hex_basis.y = grid_basis.y*2
	
	
	var hex = Vector2(10, 10)
	var pixel = hex2pixel(hex)
	print_debug(hex, ">", pixel)
	print_debug(pixel, ">", pixel2hex(pixel))
	
	LineDrawer.font_size = 8
	var color = Color(0, 1, 1)
	var selected_color = Color(1, 0, 1)

#	for x in range(-5, 5):
#		LineDrawer.DrawLine(Vector3(-100, 0, x), Vector3(100, 0, x), Color(0, 1, 0), 10000)
#	for y in range(-5, 5):
#		LineDrawer.DrawLine(Vector3(y, 0, -100), Vector3(y, 0, 100), Color(0, 1, 0), 10000)
#	LineDrawer.DrawLine(Vector3(-100, 0, 0), Vector3(100, 0, 0), Color(1, 0, 0), 10000)
#	LineDrawer.DrawLine(Vector3(0, 0, -100), Vector3(0, 0, 100), Color(1, 0, 0), 10000)

	var image = Image.new()
	image.load("res://assets/textures/noise.png")
	for x in range(-5, 5):
		for y in range(-5, 5):
			
			var pos = Vector2(x, y)
#			if pos == selected_cell:
#				_draw_cell(pos, selected_color)
#			else:
#				_draw_cell(pos, color)
			_create_mesh(pos, image)

func _add_vertex(mesh: ImmediateMesh, image: Image, center: Vector2, v: Vector2) -> float:
	var pos = center + v
	
	var uv_scale = 2.0
	var kx = int(pos.x * uv_scale / image.get_width())
	var ky = int(pos.y * uv_scale / image.get_height())
	var dx = int(round(pos.x * uv_scale - kx * image.get_width()))
	var dy = int(round(pos.y * uv_scale - ky * image.get_height()))
	
	#if dx < 0: dx = image.get_width() + dx
	#if dy < 0: dy = image.get_height() + dy
	if dx < 0: dx = abs(dx)
	if dy < 0: dy = abs(dy)
	
	var c = image.get_pixel(dx, dy)
	var h = (c.r + c.g + c.b) / 3.0 * 20.0
	
	mesh.surface_set_normal(Vector3(0, 1, 0))
	var uv = Vector2(dx * 1.0 / image.get_width(), dy * 1.0 / image.get_height())
	mesh.surface_set_uv(uv)
	mesh.surface_add_vertex(Vector3(v.x, h, v.y))
	
	return h

func _create_mesh(hex: Vector2, image: Image):
	var vv = _get_vert_hex_vertices(Vector2.ZERO)
	var center = hex2pixel(hex)


	var mi = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var v0 = Vector3(0, 0.0, 0)
	for i in range(0, vv.size() - 1):
		_add_vertex(mesh, image, center, Vector2.ZERO)
		_add_vertex(mesh, image, center, vv[i])
		_add_vertex(mesh, image, center, vv[i + 1])

	var h = _add_vertex(mesh, image, center, Vector2.ZERO)
	#LineDrawer.DrawText(Vector3(center.x, h, center.y), str(round(center * 10) / 10.0))
	
	_add_vertex(mesh, image, center, vv[vv.size() - 1])
	_add_vertex(mesh, image, center, vv[0])

	mesh.surface_end()
	mi.mesh = mesh
	
	mi.position.x = center.x * 1.05
	mi.position.y = 0
	mi.position.z = center.y * 1.05
	mi.material_overlay = load("res://assets/materials/noise_material.tres")
	add_child(mi)

func hex2pixel(hex: Vector2) -> Vector2:
	#return hex.x*hex_basis.x + hex.y*hex_basis.y
	return hex_basis.basis_xform(hex)

func pixel2hex(pixel:Vector2) -> Vector2:
	return hex_basis.affine_inverse().basis_xform(pixel)

func cell2pixel(cell: Vector2) -> Vector2:
	return cell.x*grid_basis.x + cell.y*grid_basis.y

func pixel2cell(pixel:Vector2, rounding=true) -> Vector2:
	var res = grid_basis.affine_inverse().basis_xform(pixel)
	if rounding: res = res.floor()
	return res
	
func _get_vert_hex_vertices(hex: Vector2):
	var pixel = hex2pixel(hex)
	return PackedVector2Array([
		pixel+2*grid_basis.x,
		pixel+grid_basis.x+grid_basis.y,
		pixel-grid_basis.x+grid_basis.y,
		pixel-2*grid_basis.x,
		pixel-grid_basis.x-grid_basis.y,
		pixel+grid_basis.x-grid_basis.y
	])
	
func round_hex(hex:Vector2) -> Vector2:
	var rx = round(hex.x)
	var ry = round(hex.y)
	var rz = round(-hex.x-hex.y)
	
	var x_diff = abs(hex.x-rx)
	var y_diff = abs(hex.y-ry)
	var z_diff = abs(-hex.x-hex.y-rz)
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	return Vector2(rx, ry)

func _draw_cell(hex: Vector2, color: Color):
	var center = hex2pixel(hex)
	center.x -= long * 1.5
	center.y += short * 0.2
	var verts = _get_vert_hex_vertices(hex)
	var prev = null
	var first = null
	for v in verts:
		var next = Vector3(v.x, 0.0, v.y)
		if not first:
			first = next
		if prev:
			LineDrawer.DrawLine(prev, next, color, 10000)
		prev = next
	LineDrawer.DrawLine(first, prev, color, 10000)
	
var timer = 0
func _process(delta):
	timer += delta
	
	var camera = get_viewport().get_camera_3d()
	if Input.is_action_pressed("forward"):
		var direction = camera.transform.basis.z
		direction = direction.normalized()
		camera.transform.origin -= direction * 0.5
	if Input.is_action_pressed("backward"):
		var direction = camera.transform.basis.z
		direction = direction.normalized()
		camera.transform.origin += direction * 0.5

var touch_pressed = false
var touch_start_time = 0.0
var touch_start_position = Vector2.ZERO
var camera_start_position = Vector3.ZERO
var click_delta = 0.5

func _screen_to_local(screen_position: Vector2) -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	var world_position = camera.project_position(screen_position, camera.position.y)
	world_position = to_local(world_position)
	return Vector2(world_position.x, world_position.z)

func _input(event):
	print_debug(event)

	var camera = get_viewport().get_camera_3d()
	if event is InputEventMouseMotion:
		if touch_pressed:
			var delta = _screen_to_local(event.position) - _screen_to_local(touch_start_position)
			camera.position = camera_start_position - Vector3(delta.x, 0, delta.y)
			pass
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				touch_pressed = true
				touch_start_time = timer
				touch_start_position = event.position
				camera_start_position = camera.position
				#if _check_touch(event.position, board_preview):
				#	click_preview.emit()
				#active_start_move.emit()
		else:
			if event.button_index == 1:
				touch_pressed = false
				if (timer - touch_start_time) < click_delta:
					var move_delta = (event.position - touch_start_position).length()
					if move_delta < 1.0:
						var point = _screen_to_local(event.position)
						selected_cell = round(pixel2hex(point))
						var cell = round_hex(pixel2hex(point))
						print_debug(point, ">", selected_cell, ">", cell)
						#if _check_touch(event.position, board_preview):
						#	click_preview.emit()
						#else:
						#	active_rotate.emit()
						pass
				#active_end_move.emit()
