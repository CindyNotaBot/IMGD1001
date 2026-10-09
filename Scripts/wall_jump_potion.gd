
extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("Wall Jump Unlocked!")
	Player.can_wall_jump = true

	# Show pickup popup
	var popup = get_tree().current_scene.get_node_or_null("PickupUI/UIContainer/PickupDescription")

	if popup:
		popup.show_pickup(
			"WALL JUMP UNLOCKED!",
			"Press jump while touching a wall to wall jump."
		)

	animation_player.play("wj_pickup")
	await animation_player.animation_finished
	queue_free()
