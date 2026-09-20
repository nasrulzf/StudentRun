extends Control

@onready var resume_button: TextureButton = $CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: TextureButton = $CenterContainer/VBoxContainer/RestartButton

func _ready() -> void:
	resume_button.pressed.connect(func(): GameManager.resume_game())
	restart_button.pressed.connect(func(): GameManager.start_game())
