extends Area2D
# Called when any physics body enters the planet
func _on_body_entered(body: Node) -> void:
	# Remove the ship from the scene on collision
	if body.name == "Spaceship":
		print("Ship collided with solid planet!")
		body.queue_free()
