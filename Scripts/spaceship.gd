# Spaceship.gd
extends CharacterBody2D
class_name Spaceship

@export var thrust_force   := 400.0
@export var rotation_speed := 2.0
@export var max_fuel       := 100.0
@export var max_turn_fuel  := 50.0

var current_fuel: float
var turn_fuel: float
var is_launched: bool = false
var is_orbiting: bool = false
var is_landed: bool = false

# orbit support
var orbit_center: Node2D = null
var orbit_radius: float = 0.0
var orbit_speed: float = 0.0
var orbit_angle: float = 0.0

# zoom toggle support
var zoom1 := Vector2(0.35, 0.35)
var zoom2 := Vector2(0.1, 0.1)
var using_zoom1 := true
var _zoom_pressed_prev := false

# camera reference
var cam: Camera2D = null

func _ready() -> void:
	current_fuel = max_fuel
	turn_fuel = max_turn_fuel
	# enable _process
	set_process(true)
	# cache camera and make it current
	cam = get_tree().current_scene.get_node("WorldCam") as Camera2D
	if cam:
		cam.make_current()

func launch() -> void:
	if not is_launched:
		is_launched = true
		velocity = Vector2(0, -500)

func land() -> void:
	if is_orbiting and not is_landed:
		is_landed = true
		visible = false
		velocity = Vector2.ZERO

func unland() -> void:
	if is_landed:
		is_landed = false
		visible = true

func start_orbit(center: Node2D, radius: float, speed: float) -> void:
	is_orbiting = true
	is_launched = false
	orbit_center = center
	orbit_radius = radius
	orbit_speed = speed
	orbit_angle = (global_position - center.global_position).angle()

func stop_orbit() -> void:
	is_orbiting = false
	orbit_center = null

func break_orbit() -> void:
	if is_orbiting:
		is_orbiting = false
		is_launched = true
		var radial = (global_position - orbit_center.global_position).normalized()
		var tangent = Vector2(-radial.y, radial.x)
		velocity = tangent * orbit_speed * orbit_radius
	orbit_center = null

func handle_physics(delta: float) -> void:
	if is_launched and not is_landed:
		# continuous thrust
		if Input.is_action_pressed("thrust") and current_fuel > 0:
			current_fuel -= delta
			velocity += -transform.y * thrust_force * delta
		# turning consumes turn fuel
		if Input.is_action_pressed("turn_left") and turn_fuel > 0:
			turn_fuel -= delta
			rotation -= rotation_speed * delta
		elif Input.is_action_pressed("turn_right") and turn_fuel > 0:
			turn_fuel -= delta
			rotation += rotation_speed * delta

func _physics_process(delta: float) -> void:
	if is_orbiting:
		# orbit motion
		orbit_angle += orbit_speed * delta
		global_position = orbit_center.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		rotation = orbit_angle + PI
	else:
		handle_physics(delta)
		move_and_slide()

func _process(delta: float) -> void:
	# make the camera follow the ship
	if cam:
		cam.position = global_position
	# edge-detect zoom toggle
	var zoom_pressed = Input.is_action_pressed("toggle_zoom")
	if zoom_pressed and not _zoom_pressed_prev:
		if cam:
			if using_zoom1:
				cam.zoom = zoom2
			else:
				cam.zoom = zoom1
			using_zoom1 = not using_zoom1
	_zoom_pressed_prev = zoom_pressed
