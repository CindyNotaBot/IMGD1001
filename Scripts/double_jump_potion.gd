extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("Double Jump Unlocked!")
	Player.can_double_jump = true
	animation_player.play("potion_pickup")
	await $AnimationPlayer.animation_finished
	queue_free()
