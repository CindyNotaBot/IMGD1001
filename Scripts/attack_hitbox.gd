extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $"../CollisionShape2D"

func main() -> void:
	var direction := Input.get_axis("move left", "move right")

	# Flip the sprite
	if direction > 0:
		collision_shape_2d.flip_h = false
	elif direction < 0:
		collision_shape_2d.flip_h = true

#func _on_body_entered(body: CharacterBody2D) -> void:
	#if body is ChasingEnemy:
		#print("detected a body")
		#body.take_damage(1)
	#elif (body.is_in_group("enemy")):
		#print("detected a body")
		#body.take_damage(1)
