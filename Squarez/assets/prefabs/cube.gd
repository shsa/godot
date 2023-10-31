extends Node3D

@export var color: Color = Color(0, 1, 0)

@export var highlight: bool = false

func __set_color(value):
	color = value
	var material = $Cube.get_surface_override_material(0)
	material.albedo_color = value	

func __set_highlight(value):
	highlight = value
	var material = $Cube.get_surface_override_material(0)
	if value:
		material.emission_enabled = true
		material.emission = Color(1, 1, 1)
		material.emission_energy_multiplier = 0.2
	else:
		material.emission_enabled = false	
			
func __set_highlight2(value):
	highlight = value
	var material = $Cube.get_surface_override_material(0)
	var next_pass = material.next_pass
	if value:
		next_pass.set_shader_parameter("strength", 0.2)
	else:
		next_pass.set_shader_parameter("strength", 0.0)

func update():
	__set_color(color)
	__set_highlight2(highlight)
			
func _ready():
	var material = $Cube.get_surface_override_material(0)
	var new_material = material.duplicate()
	new_material.next_pass = new_material.next_pass.duplicate()
	new_material.next_pass.shader = new_material.next_pass.shader.duplicate()
	$Cube.set_surface_override_material(0, new_material)
	update()
	
