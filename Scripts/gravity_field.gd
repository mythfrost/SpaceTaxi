extends Area2D

@export var gravity_strength: float = 70.0

func _physics_process(delta):

	for body in get_overlapping_bodies():

		if body.name == "Spaceship":

			var offset: Vector2 = global_position - body.global_position
			var distance: float = offset.length()
			if distance > 0:

				var acceleration: Vector2 = offset.normalized() * gravity_strength * delta

				body.velocity += acceleration

				var angle_to_planet: float = offset.angle()
				body.rotation = angle_to_planet - deg_to_rad(90)
