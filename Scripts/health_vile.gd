extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_label: Label = $PickupLabel

func _on_body_entered(body: Node2D) -> void:
	Player.pickup_vile()
	animation_player.play("health_vile_pickup")
	pickup_label.show()
	await $AnimationPlayer.animation_finished
	queue_free()
