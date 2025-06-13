extends Node2D

@export var orbit_center: Vector2 = Vector2.ZERO   # point to orbit around
@export var orbital_radius: float = 100.0           # distance from center
@export var orbital_speed: float = 0.5              # radians per second

var _orbit_angle: float = 0.0

func _ready() -> void:
	# initialize angle so the planet starts at its current position
	_orbit_angle = (global_position - orbit_center).angle()

func _process(delta: float) -> void:
	# advance the angle and reposition on the circle
	_orbit_angle += orbital_speed * delta
	global_position = orbit_center + Vector2(
		cos(_orbit_angle), sin(_orbit_angle)
	) * orbital_radius
