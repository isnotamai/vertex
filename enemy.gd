extends CharacterBody3D

const SPEED = 3.0
const ATTACK_RANGE = 2.5
const ATTACK_DAMAGE = 15
const ATTACK_RATE = 1.0

var health = 67
var attack_cooldown = 0.0

var player: Node3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var health_bar = $SubViewport/ProgressBar

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var target_position = player.global_position
		target_position.y = global_position.y
		look_at(target_position, Vector3.UP)
		var p_pos = Vector2(player.global_position.x, player.global_position.z)
		var e_pos = Vector2(global_position.x, global_position.z)
		var distance_to_player = p_pos.distance_to(e_pos)
		
		if distance_to_player <= ATTACK_RANGE:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
			velocity.z = move_toward(velocity.z, 0.0, SPEED)
			
			if attack_cooldown <= 0.0:
				if player.has_method("take_damage"):
					player.take_damage(ATTACK_DAMAGE)
				attack_cooldown = ATTACK_RATE
		else:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()

func take_damage():
	health -= 6.7
	if health_bar:
		health_bar.value = health
	if health <= 0:
		queue_free()
