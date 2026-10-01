extends Area2D

const MAX_HEALTH = 5
@onready var timer: Timer = $Timer
@onready var sfx_death: AudioStreamPlayer2D = $sfx_death
var can_take_damage = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter" and can_take_damage:
		Player.current_health -= 2
		_apply_iframes(1.0)
		print(Player.current_health)
		if Player.current_health <= 0:
			print("you died")
			Engine.time_scale = 0.5
			body.get_node("CollisionShape2D").queue_free()
			var death_sfx = body.get_node_or_null("sfx_death")
			if death_sfx:
				death_sfx.play() 
		
			Engine.time_scale = 0.5
			
			var collision = body.get_node_or_null("CollisionShape2D")
			if collision:
				collision.queue_free()
				timer.start()
				
func _apply_iframes(duration: float) -> void:
	can_take_damage = false
	await get_tree().create_timer(duration).timeout
	can_take_damage = true
		
		


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	Player.current_health = Player.max_health
	get_tree().reload_current_scene()
