extends Control
class_name Flame

# Defines the points that shape the flame polygon
@export var flame_points := PackedVector2Array([
	Vector2(-10,  0),
	Vector2( 10,  0),
	Vector2(  5, 40),
	Vector2(-5, 40),
])

# Called when the node is added to the scene
func _ready() -> void:
	set_process(true)
	queue_redraw()

# Called every frame
func _process(delta: float) -> void:
	queue_redraw()

# Called when the control is drawn
func _draw() -> void:
	draw_colored_polygon(flame_points, Color.DARK_RED)
