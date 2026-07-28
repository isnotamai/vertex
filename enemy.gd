extends CharacterBody3D

const SPEED = 3.0
var health = 67

var player: Node3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var health_bar = $SubViewport/ProgressBar

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	if is_instance_valid(player):
		var target_position = player.global_position
		target_position.y = global_position.y
		
		look_at(target_position, Vector3.UP)
		
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()

func take_damage():
	health -= 6.7
	health_bar.value = health
	if health <= 0:
		queue_free()
