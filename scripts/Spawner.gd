extends Node3D
# Spawns enemies around the player on a timer.

@export var enemy_scene: PackedScene
@export var spawn_interval := 1.5
@export var spawn_radius := 18.0
@export var min_distance_from_player := 12.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	if enemy_scene == null:
		enemy_scene = preload("res://scenes/enemy.tscn")
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if GameManager.game_over_flag:
		timer.stop()
		return
	_spawn_one()

func _spawn_one() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
		
	var angle := randf() * TAU
	var pos := Vector3(cos(angle) * spawn_radius, 1.0, sin(angle) * spawn_radius)
	pos += player.global_position
	
	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = pos
