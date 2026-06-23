extends Area3D
# Bullet: flies forward, hits enemies/walls, despawns.

@export var speed := 60.0
@export var lifetime := 5.0
@export var damage := 34

var direction: Vector3 = Vector3.FORWARD
var has_hit := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if has_hit:
		return
	
	if body.is_in_group("enemies"):
		has_hit = true
		body.take_damage(damage)
		_create_impact()
	elif body.name != "Player":
		has_hit = true
		_create_impact()

func _on_area_entered(area: Area3D) -> void:
	if has_hit:
		return
	
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemies"):
		has_hit = true
		parent.take_damage(damage)
		_create_impact()

func _create_impact() -> void:
	# Simple visual feedback - queue for deletion
	await get_tree().create_timer(0.05).timeout
	queue_free()
