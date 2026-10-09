extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	print("Double Jump Unlocked!")
	Player.can_double_jump = true

	var popup = get_tree().current_scene.get_node_or_null("PickupUI/UIContainer/PickupDescription")
		
	if popup:
		print("Popup found!")
		popup.show_pickup(
			"DOUBLE JUMP UNLOCKED!",
			"Press jump again while in the air to double jump."
		)
	else:
		print("Popup NOT found!")

	animation_player.play("potion_pickup")
	await animation_player.animation_finished
	queue_free()
