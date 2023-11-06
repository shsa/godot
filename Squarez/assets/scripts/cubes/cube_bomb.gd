extends CubeBase

func set_highlight(value):
	highlight = value
	var material = $Model.get_surface_override_material(0)
	var next_pass = material.next_pass
	if value:
		next_pass.set_shader_parameter("strength", 0.2)
	else:
		next_pass.set_shader_parameter("strength", 0.0)

func update():
	set_highlight(highlight)
			
func _ready():
	var material = $Model.get_surface_override_material(0)
	var new_material = material.duplicate()
	new_material.next_pass = new_material.next_pass.duplicate()
	new_material.next_pass.shader = new_material.next_pass.shader.duplicate()
	$Model.set_surface_override_material(0, new_material)
	update()

func placed():
	var explosion = ResourceLoader.load("res://assets/prefabs/explosion.tscn")
	var m = board.get_matrix()
	var jobs = Jobs.new()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var obj = explosion.instantiate()
			var pos = Vector2i(coord.x + x, coord.y + y)
			obj.position = Vector3(pos.x, position.y + 1, pos.y)
			board._pivot.add_child(obj)
			jobs.add(obj.play)
			var cube = m.get_cube(pos)
			if cube != null:
				jobs.add(cube.collapse)
		pass
	await jobs.all()

func collapse():
	queue_free()
