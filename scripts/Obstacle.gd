extends Area2D
## Generic obstacle. `required_action` decides how the player must react:
## "dodge" (rock - must lane-change, can never be jumped/slid past),
## "jump" (barrier/box - low, must jump over),
## "slide" (portal - overhead, must duck under).

@onready var sprite: Sprite2D = $Sprite2D

var required_action: String = "dodge"

func setup(tex: Texture2D, action: String, target_width: float, lane_x: float, y: float) -> void:
	required_action = action
	sprite.texture = tex
	var w: float = tex.get_width()
	if w > 0.0:
		var s: float = target_width / w
		sprite.scale = Vector2(s, s)
	position = Vector2(lane_x, y)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	position.y += GameManager.speed * delta
	if position.y > get_viewport_rect().size.y + 200.0:
		queue_free()

func on_player_hit(player) -> void:
	var passed := false
	match required_action:
		"jump":
			passed = player.state == player.PState.JUMPING
		"slide":
			passed = player.state == player.PState.SLIDING
		_:
			passed = false
	if passed:
		return
	if GameManager.shield_active:
		GameManager.shield_active = false
		queue_free()
		return
	player.die()
	GameManager.game_over()
