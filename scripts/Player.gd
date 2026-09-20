extends Area2D
## The school-kid runner. Stays at a fixed Y near the bottom of the screen;
## the world (background + obstacles + collectibles) scrolls toward the player
## instead of the player moving forward. Lane switches, jumps and slides are
## purely visual/state changes here - Obstacle.gd decides pass/fail by
## comparing its required_action against `state` when areas overlap.

signal died

enum PState { RUNNING, JUMPING, SLIDING, DEAD }

const TARGET_HEIGHT := 320.0
const JUMP_HEIGHT := 260.0
const JUMP_DURATION := 0.55
const SLIDE_DURATION := 0.6
const LANE_SWITCH_DURATION := 0.15
const SWIPE_MIN_DISTANCE := 60.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_standing: CollisionShape2D = $CollisionStanding
@onready var collision_sliding: CollisionShape2D = $CollisionSliding

var run_texture := preload("res://assets/character/run.png")
var jump_texture := preload("res://assets/character/jump.png")
var slide_texture := preload("res://assets/character/slide.png")
var hit_texture := preload("res://assets/character/hit.png")

var lane_index := 1
var lane_positions: Array = []
var base_y := 0.0
var state: PState = PState.RUNNING

var _touch_start := Vector2.ZERO
var _touch_active := false
var _lane_tween: Tween
var _jump_tween: Tween
var _slide_timer := 0.0

func setup(lanes: Array, y: float) -> void:
	lane_positions = lanes
	base_y = y
	lane_index = 1
	position = Vector2(lane_positions[lane_index], base_y)

func reset() -> void:
	if _lane_tween:
		_lane_tween.kill()
	if _jump_tween:
		_jump_tween.kill()
	state = PState.RUNNING
	sprite.position.y = 0.0
	sprite.modulate = Color.WHITE
	collision_standing.disabled = false
	collision_sliding.disabled = true
	_set_sprite_texture(run_texture)
	position = Vector2(lane_positions[lane_index], base_y)

func _ready() -> void:
	_set_sprite_texture(run_texture)
	area_entered.connect(_on_area_entered)
	set_process_unhandled_input(true)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	if state == PState.SLIDING:
		_slide_timer -= delta
		if _slide_timer <= 0.0:
			_end_slide()
	if GameManager.shield_active:
		sprite.modulate = Color(0.6, 1.0, 1.0)
	elif GameManager.speed_boost_active:
		sprite.modulate = Color(1.0, 0.9, 0.4)
	else:
		sprite.modulate = Color.WHITE

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touch_active = true
		elif _touch_active:
			_handle_swipe(event.position - _touch_start)
			_touch_active = false
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_touch_start = event.position
			_touch_active = true
		elif _touch_active:
			_handle_swipe(event.position - _touch_start)
			_touch_active = false
	elif event.is_action_pressed("lane_left"):
		move_lane(-1)
	elif event.is_action_pressed("lane_right"):
		move_lane(1)
	elif event.is_action_pressed("jump"):
		start_jump()
	elif event.is_action_pressed("slide"):
		start_slide()

func _handle_swipe(delta_vec: Vector2) -> void:
	if delta_vec.length() < SWIPE_MIN_DISTANCE:
		return
	if abs(delta_vec.x) > abs(delta_vec.y):
		move_lane(1 if delta_vec.x > 0 else -1)
	else:
		if delta_vec.y < 0:
			start_jump()
		else:
			start_slide()

func move_lane(dir: int) -> void:
	if state == PState.DEAD:
		return
	var new_lane: int = clampi(lane_index + dir, 0, lane_positions.size() - 1)
	if new_lane == lane_index:
		return
	lane_index = new_lane
	if _lane_tween:
		_lane_tween.kill()
	_lane_tween = create_tween()
	_lane_tween.tween_property(self, "position:x", lane_positions[lane_index], LANE_SWITCH_DURATION).set_trans(Tween.TRANS_SINE)

func start_jump() -> void:
	if state == PState.DEAD or state == PState.JUMPING:
		return
	if state == PState.SLIDING:
		_end_slide()
	state = PState.JUMPING
	_set_sprite_texture(jump_texture)
	if _jump_tween:
		_jump_tween.kill()
	sprite.position.y = 0.0
	_jump_tween = create_tween()
	_jump_tween.tween_property(sprite, "position:y", -JUMP_HEIGHT, JUMP_DURATION * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_jump_tween.tween_property(sprite, "position:y", 0.0, JUMP_DURATION * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_jump_tween.tween_callback(_end_jump)

func _end_jump() -> void:
	if state == PState.JUMPING:
		state = PState.RUNNING
		_set_sprite_texture(run_texture)

func start_slide() -> void:
	if state == PState.DEAD or state == PState.SLIDING:
		return
	if state == PState.JUMPING:
		if _jump_tween:
			_jump_tween.kill()
		sprite.position.y = 0.0
	state = PState.SLIDING
	_set_sprite_texture(slide_texture)
	_slide_timer = SLIDE_DURATION
	collision_standing.disabled = true
	collision_sliding.disabled = false

func _end_slide() -> void:
	if state == PState.SLIDING:
		state = PState.RUNNING
		_set_sprite_texture(run_texture)
	collision_standing.disabled = false
	collision_sliding.disabled = true

func die() -> void:
	if state == PState.DEAD:
		return
	state = PState.DEAD
	_set_sprite_texture(hit_texture)
	if _lane_tween:
		_lane_tween.kill()
	if _jump_tween:
		_jump_tween.kill()
	died.emit()

func _set_sprite_texture(tex: Texture2D) -> void:
	sprite.texture = tex
	var h: float = tex.get_height()
	if h > 0.0:
		var s: float = TARGET_HEIGHT / h
		sprite.scale = Vector2(s, s)

func _on_area_entered(area) -> void:
	if state == PState.DEAD:
		return
	if area.has_method("on_player_hit"):
		area.on_player_hit(self)
