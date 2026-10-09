extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	Player.pickup_vile()
	animation_player.play("health_vile_pickup")
	await $AnimationPlayer.animation_finished
	queue_free()
