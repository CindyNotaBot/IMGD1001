extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter":
		print("you died")
	
		var death_sfx = body.get_node_or_null("sfx_death")
		if death_sfx:
			death_sfx.play() 
	
		Engine.time_scale = 0.5
		
		var collision = body.get_node_or_null("CollisionShape2D")
		if collision:
			collision.queue_free()
		
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
