extends Control
class_name Flame

@export var flame_points := PackedVector2Array([
	Vector2(-10,  0),
	Vector2( 10,  0),
	Vector2(  5, 40),
	Vector2(-5, 40),
])

func _ready() -> void:
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_colored_polygon(flame_points, Color.DARK_RED)
