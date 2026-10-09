extends Node2D
@onready var disappear: AnimatedSprite2D = $disappear
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shadow: Node2D = $"."


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter":	
		disappear.play()
		await disappear.animation_finished
		shadow.queue_free()
