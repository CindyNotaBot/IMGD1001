class_name Door
extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_open: bool = false

func _process(delta: float) -> void:
	if not is_open and Player.got_key:
		open_door()
		
func open_door() -> void:
	is_open = true
	animation_player.play("door_open")
