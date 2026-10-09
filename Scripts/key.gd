extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	Player.got_key = true
	print("Key aquired")
	print(Player.got_key)
	animation_player.play("key_aquired")
	await $AnimationPlayer.animation_finished
	queue_free()
