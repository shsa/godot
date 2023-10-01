extends CharacterBody3D

signal hit

@export var speed = 14
@export var jump_impulse = 20
@export var fall_acceleration = 75
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
			
	if is_on_floor() and Input.is_action_pressed("jump"):
		target_velocity.y = jump_impulse
	
	velocity = target_velocity
	
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if (collision.get_collider() == null):
			continue
			
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
	
	move_and_slide()

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	print_debug("hit")
	die()