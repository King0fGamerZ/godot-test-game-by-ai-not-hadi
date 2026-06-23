extends CharacterBody3D
# Player controller: WASD movement, mouse look, click to shoot.
# Attach to a CharacterBody3D root node named "Player".

@export var move_speed := 6.0
@export var mouse_sensitivity := 0.0025
@export var fire_rate := 0.3
@export var max_health := 100

var health := max_health
var can_shoot := true
const GRAVITY := 12.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var muzzle: Marker3D = $Head/Camera3D/Muzzle
@onready var gun: MeshInstance3D = $Head/Camera3D/Gun
@onready var fire_sound: AudioStreamPlayer3D = $FireSound

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.update_health(health)

func _unhandled_input(event: InputEvent) -> void:
	# Pause/resume mouse capture with ESC
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.4, 1.4)

	if event.is_action_pressed("shoot") and can_shoot:
		_shoot()

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 5.0

	# Movement (WASD)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir.length() > 0.1:
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()

func _shoot() -> void:
	can_shoot = false
	var b := preload("res://scenes/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = muzzle.global_position
	b.direction = -camera.global_transform.basis.z.normalized()

	if fire_sound and fire_sound.stream:
		fire_sound.play()

	# Tiny recoil animation
	var tween := create_tween()
	tween.tween_property(gun, "scale", Vector3(1.2, 0.8, 1.2), 0.05)
	tween.tween_property(gun, "scale", Vector3.ONE, 0.1)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(d: int) -> void:
	health -= d
	GameManager.update_health(health)
	if health <= 0:
		GameManager.game_over()
