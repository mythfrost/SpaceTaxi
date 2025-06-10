# Spaceship.gd
extends CharacterBody2D
class_name Spaceship

# Flight/orbit flags
var is_launched = false
var is_orbiting = false
var is_landed   = false
var orbit_body: Node2D = null

# Fuel/thrust
@export var max_fuel := 175.0
var current_fuel := max_fuel
@export var thrust_power  := 500.0
@export var fuel_burn_rate := 10.0
@onready var flame = $Thrust

# Turning
@export var max_turn_fuel       := 100.0
@export var turn_fuel_burn_rate := 7.0
@export var turn_speed          := 3.0
var turn_fuel := max_turn_fuel

# Orbit parameters
var orbit_center: Vector2 = Vector2.ZERO
var _orbit_radius: float  = 0.0
var _orbit_speed: float   = 0.0
var _orbit_angle: float   = 0.0

# Damping
@export var linear_damping := 100.0

func launch() -> void:
	if is_landed:
		return
	is_orbiting = false
	is_launched = true
	velocity = Vector2.UP.rotated(rotation) * thrust_power

func land() -> void:
	# just hide and flag landed; GameStateManager handles camera/UI
	is_launched = false
	is_landed   = true
	visible     = false
	flame.visible = false

func unland() -> void:
	is_landed = false
	visible   = true

func _physics_process(delta: float) -> void:
	# orbiting and flight logic untouched here…
	pass

func start_orbit(planet_node: Node2D, radius: float, speed: float) -> void:
	# same as before
	pass

func stop_orbit() -> void:
	is_orbiting = false
