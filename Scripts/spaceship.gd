extends CharacterBody2D
class_name Spaceship

# State flags for flight and orbit modes
var is_launched = false
var is_orbiting: bool     = false
var orbit_body: Node2D = null

# Orbit parameters updated when entering orbit
var orbit_center: Vector2 = Vector2.ZERO
var _orbit_radius: float  = 0.0
var _orbit_speed: float   = 0.0
var _orbit_angle: float   = 0.0

# Primary fuel and thrust settings
@export var max_fuel := 100.0
var current_fuel := max_fuel
@export var thrust_power := 1000.0
@export var fuel_burn_rate := 20.0

# Secondary fuel and turn settings
@export var max_turn_fuel       := 100.0
@export var turn_fuel_burn_rate := 10.0
@export var turn_speed          := 3.0
var turn_fuel := max_turn_fuel

# Camera zoom presets
@export var zoom_normal := Vector2(.35, .35)
@export var zoomed_in   := Vector2(0.2, .2)
var is_zoomed := false

# Reference to the ship’s Camera2D
@onready var cam: Camera2D = $Camera2D

# Linear damping (drag) applied when coasting
@export var linear_damping := 0.5  # fraction of speed lost per second

func _ready() -> void:
	cam.make_current()

func launch() -> void:
	velocity = Vector2.UP.rotated(rotation) * thrust_power
	is_launched = true

func _physics_process(delta: float) -> void:
	if is_launched:
	# rotation input
		if turn_fuel > 0:
			var did_turn := false
			if Input.is_action_pressed("turn_left"):
				rotation -= turn_speed * delta
				did_turn = true
			elif Input.is_action_pressed("turn_right"):
				rotation += turn_speed * delta
				did_turn = true
			if did_turn:
				turn_fuel = max(turn_fuel - turn_fuel_burn_rate * delta, 0)

		# continuous thrust while holding and consuming fuel
		if Input.is_action_pressed("ui_accept") and current_fuel > 0:
			current_fuel = max(current_fuel - fuel_burn_rate * delta, 0)
			velocity += Vector2.UP.rotated(rotation) * thrust_power * delta

		# move the ship
		move_and_slide()

		# apply damping after movement and only when not thrusting or orbiting
		if not is_orbiting and not Input.is_action_pressed("ui_accept"):
			velocity = velocity.move_toward(Vector2.ZERO, linear_damping * delta)

		# orbit behavior
		if is_orbiting:
			if Input.is_action_just_pressed("ui_accept"):
				var tangent = Vector2(-sin(_orbit_angle), cos(_orbit_angle)) * _orbit_speed * _orbit_radius
				velocity = tangent
				is_orbiting = false
				return
			orbit_center = orbit_body.global_position
			_orbit_angle += _orbit_speed * delta
			global_position = orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * _orbit_radius
			return

func start_orbit(planet_node: Node2D, radius: float, speed: float) -> void:
	orbit_body    = planet_node
	_orbit_radius = radius
	var radial    = global_position - orbit_body.global_position
	_orbit_angle  = radial.angle()
	var tangent_dir = Vector2(-radial.y, radial.x).normalized()
	var tang_speed  = velocity.dot(tangent_dir)
	_orbit_speed   = 1.2 * tang_speed / radius
	is_orbiting    = true

func stop_orbit() -> void:
	is_orbiting = false

func _input(event):
	if event.is_action_pressed("toggle_zoom"):
		is_zoomed = not is_zoomed
		if is_zoomed:
			cam.zoom = zoomed_in
		else:
			cam.zoom = zoom_normal
