class_name SlimeHitBox
extends Area2D
static var max_lives := 3
static var lives := 3
@onready var timer: Timer = $Timer
var can_take_damage = true

func _on_body_entered(body: Node2D) -> void:
	if not can_take_damage:
		return
	lives -= 1
	_apply_iframes(1.0)
	print(lives)
	if lives == 0:
		print("you died")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

func _apply_iframes(duration: float) -> void:
	can_take_damage = false
	await get_tree().create_timer(duration).timeout
	can_take_damage = true

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
