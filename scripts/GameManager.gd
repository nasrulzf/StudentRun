extends Node
## Global state machine + score/economy singleton (autoloaded as "GameManager").
## Section 10 of the spec calls for MENU / PLAYING / PAUSED / GAME_OVER states
## shared across scenes via signals rather than direct node references.

enum State { MENU, PLAYING, PAUSED, GAME_OVER }

signal state_changed(new_state: State)
signal score_changed(score: int)
signal coins_changed(coins: int)
signal speed_changed(speed: float)
signal power_up_started(kind: String, duration: float)
signal power_up_ended(kind: String)

const BASE_SPEED := 500.0
const MAX_SPEED := 1400.0
const SPEED_PER_SECOND := 12.0 # difficulty curve: speed ramps with survival time
const PIXELS_PER_METER := 250.0 # world-scroll speed is in px/s; convert to "meters" for the score
const COIN_SCORE := 10

var state: State = State.MENU
var score: int = 0
var coins: int = 0
var distance_m: float = 0.0
var run_time: float = 0.0
var speed: float = BASE_SPEED
var high_score: int = 0

var magnet_active: bool = false
var shield_active: bool = false
var speed_boost_active: bool = false
var player_node: Node = null

const SAVE_PATH := "user://savegame.cfg"
const SPEED_BOOST_MULTIPLIER := 1.6

func _ready() -> void:
	_load_high_score()

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	run_time += delta
	var target_speed: float = min(MAX_SPEED, BASE_SPEED + run_time * SPEED_PER_SECOND)
	if speed_boost_active:
		target_speed *= SPEED_BOOST_MULTIPLIER
	speed = target_speed
	speed_changed.emit(speed)
	distance_m += speed * delta / PIXELS_PER_METER
	_recalculate_score()

func _recalculate_score() -> void:
	var new_score := int(distance_m) + coins * COIN_SCORE
	if new_score != score:
		score = new_score
		score_changed.emit(score)

func start_game() -> void:
	score = 0
	coins = 0
	distance_m = 0.0
	run_time = 0.0
	speed = BASE_SPEED
	magnet_active = false
	shield_active = false
	speed_boost_active = false
	_set_state(State.PLAYING)

func pause_game() -> void:
	if state == State.PLAYING:
		_set_state(State.PAUSED)

func resume_game() -> void:
	if state == State.PAUSED:
		_set_state(State.PLAYING)

func game_over() -> void:
	if state == State.GAME_OVER:
		return
	_set_state(State.GAME_OVER)
	if score > high_score:
		high_score = score
		_save_high_score()

func return_to_menu() -> void:
	_set_state(State.MENU)

func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)
	_recalculate_score()

func activate_power_up(kind_name: String, duration: float) -> void:
	match kind_name:
		"speed_boost":
			speed_boost_active = true
		"shield":
			shield_active = true
		"magnet":
			magnet_active = true
	power_up_started.emit(kind_name, duration)
	await get_tree().create_timer(duration).timeout
	match kind_name:
		"speed_boost":
			speed_boost_active = false
		"shield":
			shield_active = false
		"magnet":
			magnet_active = false
	power_up_ended.emit(kind_name)

func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(state)

func _load_high_score() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		high_score = cfg.get_value("save", "high_score", 0)

func _save_high_score() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("save", "high_score", high_score)
	cfg.save(SAVE_PATH)
