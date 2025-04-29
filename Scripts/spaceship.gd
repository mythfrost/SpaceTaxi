extends CharacterBody2D

var is_launched = false

@export var max_fuel := 100.0
var current_fuel := max_fuel
@export var thrust_power := 400.0
@export var fuel_burn_rate := 40.0
@onready var cam: Camera2D = $Camera2D

func _ready() -> void:
	cam.make_current()

func launch(degrees):
	var ang = deg_to_rad(degrees)
	velocity = Vector2(cos(ang), -sin(ang)) * 100
	is_launched = true
	print("Launched at", degrees)

func _physics_process(delta):
	if is_launched:
		if Input.is_action_pressed("ui_accept") and current_fuel > 0:
			var forward = Vector2.RIGHT.rotated(rotation)
			velocity += forward * thrust_power * delta
			current_fuel = max(current_fuel - fuel_burn_rate * delta, 0)
		move_and_slide()
