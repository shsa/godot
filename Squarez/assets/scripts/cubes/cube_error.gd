extends Node3D

func play():
	await get_tree().create_timer(1).timeout
	queue_free()
