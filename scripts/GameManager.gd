extends Node
# Autoload (singleton). Holds score, health state, and game-over signal.

signal health_changed(hp: int)
signal score_changed(s: int)
signal ammo_changed(current: int, max: int)
signal wave_changed(wave: int)
signal game_over_signal

var score: int = 0
var game_over_flag: bool = false
var current_wave: int = 1

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func reset() -> void:
	score = 0
	game_over_flag = false
	current_wave = 1
	score_changed.emit(score)
	wave_changed.emit(current_wave)

func add_score(amount: int) -> void:
	if amount > 0:
		score += amount
		score_changed.emit(score)

func update_health(hp: int) -> void:
	health_changed.emit(max(0, hp))

func update_ammo(current: int, max: int) -> void:
	ammo_changed.emit(current, max)

func update_wave(wave: int) -> void:
	current_wave = wave
	wave_changed.emit(wave)

func game_over() -> void:
	if game_over_flag:
		return
	game_over_flag = true
	get_tree().paused = true
	game_over_signal.emit()
