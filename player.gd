extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

const RECOIL_VERTUCAL = 1
const RECOIL_HORIZONTAL = 1.2
const FIRE_RATE = 0.15

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var muzzle = $Head/Camera3D/Muzzle

var bullet_scene = preload("res://bullet.tscn")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fire_cooldown = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		#rotate yaw
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		#rotate pitch
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		head.orthonormalize()
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_method("take_damage"):
			target.take_damage()
		#else:
		#	print("shoot a unval target", target.name)
	apply_recoil()
	
func apply_recoil():
	head.rotation.x += deg_to_rad(RECOIL_VERTUCAL)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	var random_h_recoil = randf_range(-RECOIL_HORIZONTAL,RECOIL_HORIZONTAL)
	rotate_y(deg_to_rad(random_h_recoil))
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov",72.0,0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera,"fov",75.0,0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _physics_process(delta):
	#gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir = Input.get_vector("move_left","move_right","move_forward","move_backward")
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
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
