extends Area3D
# Bullet: flies forward, hits enemies/walls, despawns.
# Attach to an Area3D root in Bullet.tscn with a CollisionShape3D + MeshInstance3D.

@export var speed := 45.0
@export var lifetime := 3.0
@export var damage := 34

var direction: Vector3 = Vector3.FORWARD

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
	queue_free()
