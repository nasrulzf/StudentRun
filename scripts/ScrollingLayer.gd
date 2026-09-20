extends Node2D
class_name ScrollingLayer
## Vertically-tiling parallax layer. Stacks enough copies of `texture` to
## always cover the viewport, scrolling them at speed_factor * GameManager.speed
## and recycling any tile that has scrolled fully past the bottom back above
## the topmost tile - gives an infinite vertical scroll from a single image.

@export var texture: Texture2D
@export var speed_factor: float = 1.0

var _tile_height: float = 0.0
var _tiles: Array = []

func _ready() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var scale_factor: float = vp_size.x / texture.get_width()
	_tile_height = texture.get_height() * scale_factor
	var tile_count: int = int(ceil(vp_size.y / _tile_height)) + 2
	for i in range(tile_count):
		var s := Sprite2D.new()
		s.texture = texture
		s.centered = false
		s.scale = Vector2(scale_factor, scale_factor)
		s.position = Vector2(0, i * _tile_height - _tile_height)
		add_child(s)
		_tiles.append(s)

func _process(delta: float) -> void:
	if GameManager.state != GameManager.State.PLAYING:
		return
	var dy: float = GameManager.speed * speed_factor * delta
	var vp_h: float = get_viewport_rect().size.y
	for t in _tiles:
		t.position.y += dy
	for t in _tiles:
		if t.position.y >= vp_h:
			var highest: float = t.position.y
			for o in _tiles:
				highest = min(highest, o.position.y)
			t.position.y = highest - _tile_height
