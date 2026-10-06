extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_label: Label = $PickupLabel

func _on_body_entered(body: Node2D) -> void:
	print("Wall Jump Unlocked!")
	Player.can_wall_jump = true
	
	pickup_label.show()
	
	animation_player.play("wj_pickup")
	await animation_player.animation_finished
	queue_free()
