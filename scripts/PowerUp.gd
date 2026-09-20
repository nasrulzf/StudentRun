extends Area2D
## No generated art exists yet for power-ups (see spec 4.3 / 5.9a-c), so each
## kind is drawn as a tinted circle + glyph. Swap in real icons later by
## replacing _build_visual() with a Sprite2D texture assignment.

enum Kind { SPEED, SHIELD, MAGNET }

const RADIUS := 55.0
const DURATION := 6.0

var kind: Kind = Kind.SPEED

const KIND_DATA := {
	Kind.SPEED: {"color": Color(0.20, 0.55, 1.0), "glyph": "⚡", "name": "speed_boost"},
	Kind.SHIELD: {"color": Color(0.35, 0.85, 0.9), "glyph": "🛡", "name": "shield"},
	Kind.MAGNET: {"color": Color(0.9, 0.2, 0.25), "glyph": "🧲", "name": "magnet"},
}

@onready var circle: Polygon2D = $Circle
@onready var label: Label = $Label

func setup(k: Kind, lane_x: float, y: float) -> void:
	kind = k
	position = Vector2(lane_x, y)
	_update_visual()

func _ready() -> void:
	var pts := PackedVector2Array()
	var segs := 24
	for i in range(segs):
		var a: float = TAU * i / segs
		pts.append(Vector2(cos(a), sin(a)) * RADIUS)
	circle.polygon = pts
	_update_visual()

func _update_visual() -> void:
	var data: Dictionary = KIND_DATA[kind]
	circle.color = data["color"]
	label.text = data["glyph"]

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	position.y += GameManager.speed * delta
	if position.y > get_viewport_rect().size.y + 200.0:
		queue_free()

func on_player_hit(_player: Node) -> void:
	var data: Dictionary = KIND_DATA[kind]
	GameManager.activate_power_up(data["name"], DURATION)
	queue_free()
