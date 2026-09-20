extends Control

@onready var play_button: TextureButton = $CenterContainer/VBoxContainer/PlayButton
@onready var high_score_label: Label = $CenterContainer/VBoxContainer/HighScoreLabel

func _ready() -> void:
	play_button.pressed.connect(func(): GameManager.start_game())
	visibility_changed.connect(_refresh_high_score)
	_refresh_high_score()

func _refresh_high_score() -> void:
	high_score_label.text = "Skor Tertinggi: %d" % GameManager.high_score
