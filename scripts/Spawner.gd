extends Node3D
# Spawns enemies in waves around the player with increasing difficulty.

@export var enemy_scene: PackedScene
@export var spawn_interval := 1.5
@export var spawn_radius := 20.0
@export var wave_size := 5
@export var wave_duration := 30.0

@onready var timer: Timer = $Timer

var current_wave := 1
var enemies_spawned_this_wave := 0
var wave_start_time := 0.0
var spawn_interval_base := 1.5

func _ready() -> void:
	if enemy_scene == null:
		enemy_scene = preload("res://scenes/enemy.tscn")
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	wave_start_time = Time.get_ticks_msec() / 1000.0
	GameManager.update_wave(current_wave)

func _on_timer_timeout() -> void:
	if GameManager.game_over_flag:
		timer.stop()
		return
	
	_check_wave_progression()
	_spawn_one()

func _check_wave_progression() -> void:
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - wave_start_time
	
	if elapsed_time >= wave_duration:
		# Wave complete, start next wave
		current_wave += 1
		enemies_spawned_this_wave = 0
		wave_start_time = Time.get_ticks_msec() / 1000.0
		
		# Increase difficulty
		spawn_interval = max(0.5, spawn_interval_base - (current_wave * 0.1))
		wave_size += 2
		
		timer.wait_time = spawn_interval
		GameManager.update_wave(current_wave)

func _spawn_one() -> void:
	if enemies_spawned_this_wave >= wave_size:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	enemies_spawned_this_wave += 1
	
	var angle := randf() * TAU
	var pos := Vector3(cos(angle) * spawn_radius, 1.0, sin(angle) * spawn_radius)
	pos += player.global_position
	
	var enemy := enemy_scene.instantiate()
	
	# Randomly assign enemy type based on wave
	var enemy_types = ["normal"]
	if current_wave >= 2:
		enemy_types.append("fast")
	if current_wave >= 4:
		enemy_types.append("tank")
	
	enemy.enemy_type = enemy_types[randi() % enemy_types.size()]
	
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = pos
