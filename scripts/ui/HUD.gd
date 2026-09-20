extends Control

@onready var score_label: Label = $TopBar/ScoreLabel
@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var pause_button: TextureButton = $TopBar/PauseButton

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	pause_button.pressed.connect(func(): GameManager.pause_game())
	_on_score_changed(GameManager.score)
	_on_coins_changed(GameManager.coins)

func _on_score_changed(score: int) -> void:
	score_label.text = "Skor: %d" % score

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Koin: %d" % coins
