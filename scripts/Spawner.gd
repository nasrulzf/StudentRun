extends Node2D
## Timer-based obstacle/coin/power-up spawner. Difficulty ramps by shrinking
## the spawn interval over the first 60s of a run (section 7 milestone 4).

@export var obstacle_scene: PackedScene
@export var coin_scene: PackedScene
@export var power_up_scene: PackedScene

const SPAWN_Y := -150.0
const MIN_INTERVAL := 0.55
const MAX_INTERVAL := 1.3
const POWER_UP_CHANCE := 0.06
const COIN_ROW_CHANCE := 0.5

var lane_positions: Array = []
var rng := RandomNumberGenerator.new()
var _timer := 0.0
var _next_interval := 1.0

var _obstacle_defs: Array = [
	{"texture": preload("res://assets/obstacles/rock.png"), "action": "dodge", "width": 260.0},
	{"texture": preload("res://assets/obstacles/barrier.png"), "action": "jump", "width": 300.0},
	{"texture": preload("res://assets/obstacles/box_stack.png"), "action": "jump", "width": 240.0},
	{"texture": preload("res://assets/obstacles/box_crate.png"), "action": "jump", "width": 240.0},
	{"texture": preload("res://assets/obstacles/portal.png"), "action": "slide", "width": 320.0},
]
var _coin_texture := preload("res://assets/collectibles/coin.png")

func setup(lanes: Array) -> void:
	lane_positions = lanes
	rng.randomize()
	_schedule_next()

func _schedule_next() -> void:
	var difficulty: float = clamp(GameManager.run_time / 60.0, 0.0, 1.0)
	var interval: float = lerp(MAX_INTERVAL, MIN_INTERVAL, difficulty)
	_next_interval = rng.randf_range(interval * 0.8, interval * 1.2)
	_timer = 0.0

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	_timer += delta
	if _timer >= _next_interval:
		_spawn_wave()
		_schedule_next()

func _spawn_wave() -> void:
	var roll: float = rng.randf()
	if roll < POWER_UP_CHANCE:
		_spawn_power_up()
	elif roll < POWER_UP_CHANCE + COIN_ROW_CHANCE:
		_spawn_coin_row()
	else:
		_spawn_obstacle()

func _spawn_obstacle() -> void:
	var def: Dictionary = _obstacle_defs[rng.randi_range(0, _obstacle_defs.size() - 1)]
	var lane: int = rng.randi_range(0, lane_positions.size() - 1)
	var obs = obstacle_scene.instantiate()
	add_child(obs)
	obs.setup(def["texture"], def["action"], def["width"], lane_positions[lane], SPAWN_Y)

func _spawn_coin_row() -> void:
	var lane: int = rng.randi_range(0, lane_positions.size() - 1)
	var count: int = rng.randi_range(3, 6)
	for i in range(count):
		var coin = coin_scene.instantiate()
		add_child(coin)
		coin.setup(_coin_texture, lane_positions[lane], SPAWN_Y - i * 90.0)

func _spawn_power_up() -> void:
	var lane: int = rng.randi_range(0, lane_positions.size() - 1)
	var kind: int = rng.randi_range(0, 2)
	var pu = power_up_scene.instantiate()
	add_child(pu)
	pu.setup(kind, lane_positions[lane], SPAWN_Y)
