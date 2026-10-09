
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	# Keep your existing health vial collection code here.
	# For example, your original Player.pickup_vile() call.

	Player.pickup_vile()

	# Show pickup popup
	var popup = get_tree().current_scene.get_node_or_null(
		"PickupUI/UIContainer/PickupDescription"
	)

	if popup:
		popup.show_pickup(
			"HEALTH VIAL COLLECTED!",
			"Collect health vials to increase your health progress."
		)

	queue_free()
