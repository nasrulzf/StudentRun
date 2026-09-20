extends Area2D

const TARGET_WIDTH := 170.0
const MAGNET_PULL_SPEED := 900.0

@onready var sprite: Sprite2D = $Sprite2D

func setup(tex: Texture2D, lane_x: float, y: float) -> void:
	sprite.texture = tex
	var w: float = tex.get_width()
	if w > 0.0:
		var s: float = TARGET_WIDTH / w
		sprite.scale = Vector2(s, s)
	position = Vector2(lane_x, y)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	position.y += GameManager.speed * delta
	if GameManager.magnet_active and GameManager.player_node:
		var target_x: float = GameManager.player_node.global_position.x
		position.x = move_toward(position.x, target_x, MAGNET_PULL_SPEED * delta)
	if position.y > get_viewport_rect().size.y + 200.0:
		queue_free()

func on_player_hit(_player: Node) -> void:
	GameManager.add_coin()
	queue_free()
