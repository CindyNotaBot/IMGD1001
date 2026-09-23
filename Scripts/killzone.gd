extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter":
		print("you died")
		Engine.time_scale = 0.5
		
		var collision = body.get_node_or_null("CollisionShape2D")
		if collision:
			collision.queue_free()
		
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
