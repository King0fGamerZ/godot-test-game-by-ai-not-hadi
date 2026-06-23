extends Node
# Autoload (singleton). Holds score, health state, and game-over signal.

signal health_changed(hp: int)
signal score_changed(s: int)
signal game_over_signal

var score: int = 0
var game_over_flag: bool = false
var _initial_score: int = 0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS  # Keeps running even when paused

func reset() -> void:
	score = 0
	game_over_flag = false
	score_changed.emit(score)

func add_score(amount: int) -> void:
	if amount > 0:
		score += amount
		score_changed.emit(score)

func update_health(hp: int) -> void:
	health_changed.emit(max(0, hp))

func game_over() -> void:
	if game_over_flag:
		return
	game_over_flag = true
	get_tree().paused = true
	game_over_signal.emit()
