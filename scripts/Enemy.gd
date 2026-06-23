extends CharacterBody3D
# Enemy: walks toward player, deals damage on contact, dies when shot enough.

@export var speed := 3.5
@export var damage := 10
@export var max_health := 50
@export var gravity := 20.0

var health := max_health
var player: Node3D = null

@onready var mesh: MeshInstance3D = $Mesh
@onready var hitbox: Area3D = $Hitbox

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
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
		
	var dir := (player.global_position - global_position)
	dir.y = 0
	
	if dir.length() > 0.1:
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

	move_and_slide()

func take_damage(d: int) -> void:
	health -= d
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
		(mat as StandardMaterial3D).albedo_color = Color.WHITE
		await get_tree().create_timer(0.08).timeout
		if is_instance_valid(self):
			(mat as StandardMaterial3D).albedo_color = original

func die() -> void:
	GameManager.add_score(10)
	queue_free()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		die()
