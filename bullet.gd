extends Area3D

const SPEED = 40.0
const MAX_LIFETIME = 10.0
var current_lifetime = 0.0

func _process(delta):
	position -= transform.basis.z * SPEED * delta
	current_lifetime += delta
	if current_lifetime >= MAX_LIFETIME:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		return
		
	if body.has_method("take_damage"):
		body.take_damage()
	
	queue_free()
