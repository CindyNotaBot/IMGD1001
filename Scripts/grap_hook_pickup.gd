extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_label: Label = $PickupLabel

func _on_body_entered(body: Node2D) -> void:
	print("Grappling Hook Unlocked!")
	Player.can_grapple = true
	
	pickup_label.show()
	
	animation_player.play("grap_hook_pickup")
	await $AnimationPlayer.animation_finished
	queue_free()
