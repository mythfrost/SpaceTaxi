extends CharacterBody2D
class_name Spaceship

# State flags
var is_launched = false
var is_orbiting: bool = false
var is_landed = false
var orbit_body: Node2D = null

# Orbit parameters
var orbit_center: Vector2 = Vector2.ZERO
var _orbit_radius: float = 0.0
var _orbit_speed: float = 0.0
var _orbit_angle: float = 0.0

# Thrust settings
@export var max_fuel := 175.0
var current_fuel := max_fuel
@export var thrust_power := 500.0
@export var fuel_burn_rate := 10.0
@onready var flame = $thrust

# Turn settings
@export var max_turn_fuel := 100.0
@export var turn_fuel_burn_rate := 7.0
@export var turn_speed := 3.0
var turn_fuel := max_turn_fuel

# Zoom presets
@export var zoom_normal := Vector2(.35,.35)
@export var zoomed_in   := Vector2(.12,.12)
var is_zoomed = false

# Damping
@export var linear_damping := 100.0

# Quests
@export var quests := [
	"Deliver supplies to Planet Zephyr",
	"Deliver mysterious officer to crime scene",
	"Deliver architect to city of Orion",
	"Deliver scientists to the anomaly at Helios"
]
var active_quest := ""
@onready var quest_label: Label = get_tree().get_current_scene().get_node("CanvasLayer2/QuestLabel")

func _ready() -> void:
	flame.visible = false

func launch() -> void:
	is_orbiting = false 
	is_landed = false
	if is_landed:
		return
	velocity = Vector2.UP.rotated(rotation) * thrust_power
	is_launched = true

func land() -> void:
	is_launched = false
	visible = false
	flame.visible = false
	is_landed = true
	if active_quest == "":
		active_quest = quests[randi() % quests.size()]
		quest_label.text = active_quest
		var planet_list = get_tree().get_nodes_in_group("Planets")
		var target_planet = planet_list[randi() % planet_list.size()]
		get_tree().get_current_scene().call_deferred("set_arrow_target", target_planet)

func unland() -> void:
	visible = true
	is_landed = false
	get_tree().get_current_scene().call_deferred("set_ship_camera")
	get_tree().get_current_scene().call_deferred("show_launch_button")

func _physics_process(delta: float) -> void:
	# 1) Orbit logic runs regardless of launch state
	if is_orbiting:
		# exit orbit on thrust key (Space)
		if Input.is_action_just_pressed("ui_accept"):
			var tangent = Vector2(-sin(_orbit_angle), cos(_orbit_angle)) * _orbit_speed * _orbit_radius
			velocity = tangent
			is_orbiting = false
			is_launched = true
			return

		# update center & angle
		orbit_center = orbit_body.global_position
		_orbit_angle += _orbit_speed * delta

		# move & rotate tangentially
		global_position = orbit_center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * _orbit_radius
		var tangent_dir = Vector2(-sin(_orbit_angle), cos(_orbit_angle))
		if _orbit_speed < 0.0:
			tangent_dir = -tangent_dir
		rotation = tangent_dir.angle() + PI * 0.5
		return

	# 2) Flight logic when launched
	if is_launched:
		# Handle rotation input
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

		# Apply thrust and update flame visibility
		var thrusting = Input.is_action_pressed("ui_accept") and current_fuel > 0
		if thrusting:
			current_fuel = max(current_fuel - fuel_burn_rate * delta, 0)
			velocity += Vector2.UP.rotated(rotation) * thrust_power * delta
		flame.visible = thrusting

		# Move and apply damping when coasting
		move_and_slide()
		if not thrusting:
			velocity = velocity.move_toward(Vector2.ZERO, linear_damping * delta)
		return



func start_orbit(planet_node: Node2D, radius: float, speed: float) -> void:
	orbit_body = planet_node
	_orbit_radius = radius
	var radial = global_position - orbit_body.global_position
	_orbit_angle = radial.angle()
	var tangent_dir = Vector2(-radial.y, radial.x).normalized()
	var tang_speed = velocity.dot(tangent_dir)
	_orbit_speed = 1.2 * tang_speed / radius
	is_orbiting = true

func stop_orbit() -> void:
	is_orbiting = false

func _input(event):
	if event.is_action_pressed("toggle_zoom"):
		is_zoomed = not is_zoomed
		if is_zoomed:
			$Camera2D.zoom = zoomed_in
		else:
			$Camera2D.zoom = zoom_normal

	if event is InputEventKey and event.is_action_pressed("land"):
		if is_orbiting and not is_landed:
			land()
		elif is_landed:
			unland()
