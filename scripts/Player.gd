extends CharacterBody3D
# Player controller: WASD movement, mouse look, click to shoot, reload, sprint.

@export var move_speed := 8.0
@export var sprint_speed := 14.0
@export var mouse_sensitivity := 0.002
@export var fire_rate := 0.1
@export var reload_time := 1.5
@export var max_health := 100
@export var jump_force := 8.0
@export var magazine_size := 30
@export var max_ammo := 120

var health := max_health
var can_shoot := true
var is_reloading := false
var gravity := 20.0
var current_ammo := magazine_size
var total_ammo := max_ammo

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var muzzle: Marker3D = $Head/Camera3D/Muzzle
@onready var gun: MeshInstance3D = $Head/Camera3D/Gun
@onready var fire_sound: AudioStreamPlayer3D = $FireSound

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.update_health(health)
	GameManager.update_ammo(current_ammo, magazine_size)
	velocity = Vector3.ZERO

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
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

	if event.is_action_pressed("shoot") and can_shoot and not is_reloading and current_ammo > 0:
		_shoot()
	
	if event.is_action_pressed("reload"):
		_reload()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Movement (WASD)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint (Shift key)
	var current_speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed
	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed

	move_and_slide()

func _shoot() -> void:
	can_shoot = false
	current_ammo -= 1
	GameManager.update_ammo(current_ammo, magazine_size)
	
	var b := preload("res://scenes/bullet.tscn").instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = muzzle.global_position
	b.direction = -camera.global_transform.basis.z.normalized()

	if fire_sound and fire_sound.stream:
		fire_sound.play()

	# Recoil animation
	var tween: Tween = create_tween()
	tween.tween_property(gun, "scale", Vector3(1.1, 0.9, 1.1), 0.05)
	tween.tween_property(gun, "scale", Vector3.ONE, 0.1)
	
	# Auto reload when ammo depleted
	if current_ammo <= 0:
		_reload()
		can_shoot = true
		return

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func _reload() -> void:
	if is_reloading or total_ammo <= 0 or current_ammo == magazine_size:
		return
	
	is_reloading = true
	can_shoot = false
	
	# Reload animation
	var tween: Tween = create_tween()
	tween.tween_property(gun, "position", gun.position + Vector3(0, -0.5, 0), reload_time / 2)
	tween.tween_property(gun, "position", gun.position, reload_time / 2)
	
	await get_tree().create_timer(reload_time).timeout
	
	# Refill magazine
	var ammo_needed: int = magazine_size - current_ammo
	var ammo_to_add: int = min(ammo_needed, total_ammo)
	current_ammo += ammo_to_add
	total_ammo -= ammo_to_add
	
	GameManager.update_ammo(current_ammo, magazine_size)
	is_reloading = false
	can_shoot = true

func take_damage(d: int) -> void:
	health -= d
	GameManager.update_health(health)
	if health <= 0:
		GameManager.game_over()
