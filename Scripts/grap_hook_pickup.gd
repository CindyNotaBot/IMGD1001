
extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var collected = false

func _on_body_entered(body: Node2D) -> void:
	if not body is Player or collected:
		return

	collected = true
	print("Grappling Hook Unlocked!")
	Player.can_grapple = true

	# Show pickup popup
	var popup = get_tree().current_scene.get_node_or_null(
		"PickupUI/UIContainer/PickupDescription"
	)

	if popup:
		popup.show_pickup(
			"GRAPPLING HOOK UNLOCKED!",
			"Left click to grapple onto special surfaces."
		)

	# Play pickup animation
	animation_player.play("grap_pickup")

	# Remove pickup after a short delay
	await get_tree().create_timer(0.5).timeout
	queue_free()
