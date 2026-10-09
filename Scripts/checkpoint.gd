extends Area2D
var print_count = 1

@export var spawn_offset: Vector2 = Vector2(0, -16)

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if print_count != 0:
		print("Checkpoint reached!")
		print_count = 0
	if body.is_in_group("dummyCharacter") or body.name == "dummyCharacter":
		Global.last_checkpoint_pos = global_position + spawn_offset
