extends Control

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $Panel/VBoxContainer/HighScoreLabel
@onready var restart_button: TextureButton = $Panel/VBoxContainer/ButtonRow/RestartButton
@onready var menu_button: TextureButton = $Panel/VBoxContainer/ButtonRow/MenuButton

func _ready() -> void:
	restart_button.pressed.connect(func(): GameManager.start_game())
	menu_button.pressed.connect(func(): GameManager.return_to_menu())
	visibility_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if not visible:
		return
	score_label.text = "Skor: %d" % GameManager.score
	high_score_label.text = "Skor Tertinggi: %d" % GameManager.high_score
