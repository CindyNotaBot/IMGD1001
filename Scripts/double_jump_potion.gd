extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_label: Label = $PickupLabel

func _on_body_entered(body: Node2D) -> void:
	Player.can_double_jump = true

	pickup_label.show()

	animation_player.play("potion_pickup")

	await get_tree().create_timer(8.0).timeout
	queue_free()
