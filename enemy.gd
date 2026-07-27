extends CharacterBody3D

const SPEED = 3
var health = 10

var player: Node3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	player = get_tree().get_first_node_in_group("player")
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y = gravity * delta
		
	if not is_instance_valid(player):
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.z = move_toward(velocity.z,0,SPEED)
		move_and_slide()
		return
	var direction = (player.global_position - global_position).normalized()
	
	if direction:
		var look_target = player.global_position
		look_target.y = global_position.y
		look_at(look_target,Vector3.UP)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.z = move_toward(velocity.z,0,SPEED)
		
	move_and_slide()
	
func take_damage():
	health -= 1
	if health <= 0:
		queue_free()
	
