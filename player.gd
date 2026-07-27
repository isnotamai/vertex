extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3.0
const SENSITIVITY = 0.002
const RECOIL_VERTICAL = 1.0
const RECOIL_HORIZONTAL = 1.2
const FIRE_RATE = 0.15

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var muzzle = $Head/Camera3D/WeaponContainer/Muzzle

var bullet_scene = preload("res://bullet.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fire_cooldown = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * SENSITIVITY
		head.rotation.x -= event.relative.y * SENSITIVITY
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation = Vector3.ZERO
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
func _input(event):
	if event is InputEventMouseMotion:

		rotation.y -= event.relative.x * SENSITIVITY

		head.rotation.x -= event.relative.y * SENSITIVITY
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		camera.rotation = Vector3.ZERO
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle.global_position
	raycast.force_raycast_update()

	var target_point: Vector3
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		var distance = camera.global_position.distance_to(hit_point)
		
		if distance < 5.0:
			target_point = camera.global_position - camera.global_transform.basis.z * 5.0
		else:
			target_point = hit_point
	else:
		target_point = raycast.to_global(raycast.target_position)
	bullet.look_at(target_point, Vector3.UP)
	apply_recoil()

func apply_recoil():
	head.rotation.x += deg_to_rad(RECOIL_VERTICAL)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	var random_h_recoil = randf_range(-RECOIL_HORIZONTAL, RECOIL_HORIZONTAL)
	rotation.y += deg_to_rad(random_h_recoil)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", 72.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 75.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if fire_cooldown > 0.0:
		fire_cooldown -= delta
		
	if Input.is_action_pressed("fire") and fire_cooldown <= 0:
		shoot()
		fire_cooldown = FIRE_RATE
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
		
	move_and_slide()


func _on_timer_timeout() -> void:
	pass # Replace with function body.
