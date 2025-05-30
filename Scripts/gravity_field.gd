extends Area2D

@export var orbit_distance := 600.0
@export var orbit_speed    := 1.8
var orbit_body: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Spaceship:
		var planet = get_parent()   # the Node2D above this Area2D
		body.start_orbit(get_parent(), orbit_distance, orbit_speed)

func _on_body_exited(body: Node) -> void:
	# only stop orbit if the ship has already left orbit mode
	if body is Spaceship and not body.is_orbiting:
		body.stop_orbit()
