extends CharacterBody3D
# Enemy: walks toward player, deals damage on contact, dies when shot enough.

@export var speed := 4.0
@export var damage := 10
@export var max_health := 50
@export var gravity := 20.0
@export var detection_range := 50.0
@export var enemy_type := "normal"  # "normal", "fast", "tank"

var health := max_health
var player: Node3D = null
var is_detected := false
var last_damage_time := 0.0

@onready var mesh: MeshInstance3D = $Mesh
@onready var hitbox: Area3D = $Hitbox

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	
	# Adjust enemy properties based on type
	match enemy_type:
		"fast":
			speed = 6.0
			max_health = 25
			health = max_health
			damage = 8
		"tank":
			speed = 2.5
			max_health = 100
			health = max_health
			damage = 15
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	
	if player == null:
		move_and_slide()
		return
	
	var distance_to_player := global_position.distance_to(player.global_position)
	
	# Detect player
	if distance_to_player < detection_range:
		is_detected = true
	
	if is_detected:
		var dir := (player.global_position - global_position)
		dir.y = 0
		
		if dir.length() > 0.5:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			
			# Face the player (only Y rotation)
			var look_target := global_position + dir
			look_target.y = global_position.y
			look_at(look_target, Vector3.UP)
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func take_damage(d: int) -> void:
	health -= d
	last_damage_time = Time.get_ticks_msec()
	_flash_red()
	if health <= 0:
		die()

func _flash_red() -> void:
	if mesh == null:
		return
	var mat := mesh.get_surface_override_material(0)
	if mat == null:
		mat = mesh.mesh.surface_get_material(0)
	if mat is StandardMaterial3D:
		var original := (mat as StandardMaterial3D).albedo_color
		(mat as StandardMaterial3D).albedo_color = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			(mat as StandardMaterial3D).albedo_color = original

func die() -> void:
	var score_value = 10
	if enemy_type == "fast":
		score_value = 15
	elif enemy_type == "tank":
		score_value = 25
	
	GameManager.add_score(score_value)
	queue_free()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		die()
