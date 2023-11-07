extends MeshInstance3D

func _ready():
	var material = get_surface_override_material(0)
	var new_material = material.duplicate()
	new_material.shader = new_material.shader.duplicate()
	new_material.set_shader_parameter("offset", Vector2(randf(), randf()))
	new_material.set_shader_parameter("scale", 0.2)
	set_surface_override_material(0, new_material)

func set_highlight(value):
	var material = get_surface_override_material(0)
	if value:
		material.set_shader_parameter("highlight", 0.2)
	else:
		material.set_shader_parameter("highlight", 0.0)
