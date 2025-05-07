extends Area2D

@export var orbit_distance := 400.0
@export var orbit_speed    := 1.0

func _ready() -> void:
	print("🔭 Gravity field ready at ", global_position)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	print("➡️ Body entered area:", body.name)
	if body is Spaceship:
		print("   → Starting orbit on ", body.name, 
			  "  dist=", orbit_distance, 
			  "  speed=", orbit_speed)
		body.start_orbit(global_position, orbit_distance, orbit_speed)

func _on_body_exited(body: Node) -> void:
	print("⬅️ Body exited area:", body.name)
	if body is Spaceship:
		body.stop_orbit()
