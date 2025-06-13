extends CharacterBody2D
class_name Spaceship

# —— Quest pool for “obtain_quest” ——  
@export var quests: Array = [  
	"Deliver supplies to Planet Zephyr",  
	"Deliver mysterious officer to crime scene",  
	"Deliver architect to city of Orion",  
	"Deliver scientists to the anomaly at Helios"  
]

# —— Core flight settings ——
@export var thrust_force:        float = 1000.0
@export var thrust_burn_rate:    float = 7.0
@export var rotation_speed:      float = 2.0
@export var turn_fuel_burn_rate: float = 5.0
@export var linear_damping:      float = 100.0

# —— Fuel & state ——
@export var max_fuel:      float = 100.0
@export var max_turn_fuel: float = 50.0
var current_fuel: float
var turn_fuel:    float
var is_launched:  bool = false
var is_orbiting:  bool = false

# —— Orbit params ——
var orbit_body:   Node2D = null
var orbit_radius: float  = 0.0
var orbit_speed:  float  = 0.0
var orbit_angle:  float  = 0.0

# —— Flame effect ——
@onready var flame = $thrust

# —— Zoom presets ——
@export var zoom1: Vector2 = Vector2(0.35, 0.35)
@export var zoom2: Vector2 = Vector2(0.15, 0.15)
var using_zoom1: bool = true
var _zoom_prev:   bool = false

# —— Camera ref ——
var cam: Camera2D = null

func _ready() -> void:
	current_fuel = max_fuel
	turn_fuel    = max_turn_fuel
	flame.visible = false
	set_physics_process(true)

	# cache & activate WorldCam
	var scene = get_tree().current_scene
	if scene:
		cam = scene.get_node("WorldCam") as Camera2D
		if cam:
			cam.make_current()

func launch() -> void:
	# clear any orbit before applying impulse
	if is_orbiting:
		is_orbiting = false
		orbit_body  = null
	visible = true
	if not is_launched:
		is_launched = true
		velocity    = Vector2.UP.rotated(rotation) * thrust_force

func start_orbit(body: Node2D, radius: float, speed: float) -> void:
	is_orbiting   = true
	is_launched   = false
	orbit_body    = body
	orbit_radius  = radius

	# compute initial angle & directional sign
	var offset      = global_position - body.global_position
	orbit_angle    = offset.angle()
	var tangent_dir = Vector2(-offset.y, offset.x).normalized()
	var tang_speed  = velocity.dot(tangent_dir)
	if tang_speed >= 0.0:
		orbit_speed = speed
	else:
		orbit_speed = -speed

func break_orbit() -> void:
	if is_orbiting:
		# clear orbit state
		is_orbiting = false
		orbit_body  = null
		# apply tangent impulse
		var tangent = Vector2(-sin(orbit_angle), cos(orbit_angle)) * orbit_speed * orbit_radius
		velocity    = tangent
		is_launched = true

func stop_orbit() -> void:
	is_orbiting = false
	orbit_body  = null

func _physics_process(delta: float) -> void:
	# — Orbiting —
	if is_orbiting and orbit_body:
		if Input.is_action_pressed("ui_accept"):
			break_orbit()
			return

		orbit_angle += orbit_speed * delta
		var center = orbit_body.global_position
		global_position = center + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius

		var tdir = Vector2(-sin(orbit_angle), cos(orbit_angle))
		if orbit_speed < 0.0:
			tdir = -tdir
		rotation = tdir.angle() + PI * 0.5
		return

	# — Flight —
	if is_launched:
		var thrusting = Input.is_action_pressed("thrust") or Input.is_action_pressed("ui_accept")
		if thrusting and current_fuel > 0.0:
			current_fuel -= thrust_burn_rate * delta
			velocity    += Vector2.UP.rotated(rotation) * thrust_force * delta
			flame.visible = true
		else:
			flame.visible = false

		if Input.is_action_pressed("turn_left") and turn_fuel > 0.0:
			turn_fuel -= turn_fuel_burn_rate * delta
			rotation   -= rotation_speed * delta
		elif Input.is_action_pressed("turn_right") and turn_fuel > 0.0:
			turn_fuel -= turn_fuel_burn_rate * delta
			rotation   += rotation_speed * delta

	move_and_slide()
	if is_launched and not (Input.is_action_pressed("thrust") or Input.is_action_pressed("ui_accept")):
		velocity = velocity.move_toward(Vector2.ZERO, linear_damping * delta)

func _process(delta: float) -> void:
	# camera follow
	if cam:
		cam.global_position = global_position

	# zoom toggle
	if cam:
		var z = Input.is_action_pressed("toggle_zoom")
		if z and not _zoom_prev:
			if using_zoom1:
				cam.zoom = zoom2
			else:
				cam.zoom = zoom1
			using_zoom1 = not using_zoom1
		_zoom_prev = z
