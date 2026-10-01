extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("Wall Jump Unlocked!")
	Player.can_wall_jump = true
	animation_player.play("wj_pickup")
	await $AnimationPlayer.animation_finished
	queue_free()
