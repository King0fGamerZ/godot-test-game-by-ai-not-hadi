extends CanvasLayer
# HUD + Game Over screen. Attach to a CanvasLayer in Main.tscn.

@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var crosshair: Control = $HUD/Crosshair
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var quit_button: Button = $GameOverPanel/VBoxContainer/QuitButton

func _ready() -> void:
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over_signal.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	game_over_panel.visible = false

func _on_health_changed(hp: int) -> void:
	health_label.text = "HP: %d" % hp

func _on_score_changed(s: int) -> void:
	score_label.text = "Score: %d" % s

func _on_game_over() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_panel.visible = true
	final_score_label.text = "Final Score: %d" % GameManager.score

func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
