extends Area3D
# Bullet: flies forward, hits enemies/walls, despawns.

@export var speed := 50.0
@export var lifetime := 5.0
@export var damage := 34

var direction: Vector3 = Vector3.FORWARD

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
	elif body.name != "Player":  # Don't destroy when hitting player
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemies"):
		if area.get_parent().is_in_group("enemies"):
			area.get_parent().take_damage(damage)
		queue_free()
