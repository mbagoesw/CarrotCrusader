extends Area2D

var travelled_distance = 0
const SPEED = 1000
const RANGE = 1200

func _physics_process(delta):
	# Move the bullet forward
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	
	# Track travelled distance and delete the bullet if it exceeds its range
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	# Destroy the bullet upon collision and deal damage if applicable
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
