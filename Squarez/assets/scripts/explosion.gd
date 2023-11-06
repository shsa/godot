extends Node3D

@onready var particles := $Particles

func _ready():
	particles.one_shot = true
	particles.emitting = false

func play():
	particles.emitting = true
	var time = (particles.lifetime * 2) / particles.speed_scale
	await get_tree().create_timer(time).timeout
	queue_free()
