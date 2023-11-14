extends CubeBase

class_name Rocket

@onready var _particles := $particles

func init():
	rotation = Vector3(0, randi_range(0, 3) * PI / 2, 0)

func start():
	_particles.show()
