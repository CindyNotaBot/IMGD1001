extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("Grappling Hook Unlocked!")
	Grapple.can_grapple = true
	animation_player.play("grap_hook_pickup")
	await $AnimationPlayer.animation_finished
	queue_free()
