extends Node3D

@export var color: Color = Color(0, 1, 0):
	set(value):
		color = value
		var material = $Cube.get_surface_override_material(0)
		material.albedo_color = value
