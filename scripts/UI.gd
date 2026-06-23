extends CanvasLayer
# HUD + Game Over screen with enhanced UI.

@onready var score_label: Label = $HUD/ScoreLabel
@onready var health_label: Label = $HUD/HealthLabel
@onready var ammo_label: Label = $HUD/AmmoLabel
@onready var wave_label: Label = $HUD/WaveLabel
@onready var crosshair: Control = $HUD/Crosshair
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var wave_reached_label: Label = $GameOverPanel/VBoxContainer/WaveReachedLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var quit_button: Button = $GameOverPanel/VBoxContainer/QuitButton

func _ready() -> void:
	if GameManager:
		GameManager.health_changed.connect(_on_health_changed)
		GameManager.score_changed.connect(_on_score_changed)
		GameManager.ammo_changed.connect(_on_ammo_changed)
		GameManager.wave_changed.connect(_on_wave_changed)
		GameManager.game_over_signal.connect(_on_game_over)
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	if game_over_panel:
		game_over_panel.visible = false

func _on_health_changed(hp: int) -> void:
	if health_label:
		health_label.text = "HP: %d" % hp

func _on_score_changed(s: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % s

func _on_ammo_changed(current: int, max: int) -> void:
	if ammo_label:
		ammo_label.text = "Ammo: %d/%d" % [current, max]
		# Warning color when low on ammo
		if current < 5:
			ammo_label.modulate = Color.RED
		elif current < 10:
			ammo_label.modulate = Color.YELLOW
		else:
			ammo_label.modulate = Color.WHITE

func _on_wave_changed(wave: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % wave

func _on_game_over() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if game_over_panel:
		game_over_panel.visible = true
	if final_score_label:
		final_score_label.text = "Final Score: %d" % GameManager.score
	if wave_reached_label:
		wave_reached_label.text = "Wave Reached: %d" % GameManager.current_wave

func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
