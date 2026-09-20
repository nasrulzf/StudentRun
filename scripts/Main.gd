extends Node2D

@onready var player = $World/Player
@onready var spawner = $World/Spawner
@onready var main_menu: Control = $UI/MainMenu
@onready var hud: Control = $UI/HUD
@onready var pause_menu: Control = $UI/PauseMenu
@onready var game_over_screen: Control = $UI/GameOverScreen

func _ready() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var lane_w: float = vp_size.x / 3.0
	var lanes: Array = [lane_w * 0.5, lane_w * 1.5, lane_w * 2.5]
	player.setup(lanes, vp_size.y * 0.82)
	spawner.setup(lanes)
	GameManager.player_node = player
	GameManager.state_changed.connect(_on_state_changed)
	_on_state_changed(GameManager.state)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if GameManager.state == GameManager.State.PLAYING:
			GameManager.pause_game()
		elif GameManager.state == GameManager.State.PAUSED:
			GameManager.resume_game()

func _on_state_changed(state: int) -> void:
	main_menu.visible = state == GameManager.State.MENU
	hud.visible = state == GameManager.State.PLAYING or state == GameManager.State.PAUSED
	pause_menu.visible = state == GameManager.State.PAUSED
	game_over_screen.visible = state == GameManager.State.GAME_OVER
	if state == GameManager.State.PLAYING and GameManager.run_time == 0.0:
		_reset_world()

func _reset_world() -> void:
	for child in spawner.get_children():
		child.queue_free()
	player.reset()
