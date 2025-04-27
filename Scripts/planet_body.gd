extends Area2D

func _on_body_entered(body: Node) -> void:
	if body.name == "Spaceship":
		print("Ship collided with solid planet!")
		body.queue_free()
