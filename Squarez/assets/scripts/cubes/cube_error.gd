extends CubeBase

func play():
	await get_tree().create_timer(1).timeout
	queue_free()
