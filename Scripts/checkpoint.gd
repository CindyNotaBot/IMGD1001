extends Area2D

var print_count = 1
var activated = false

@export var spawn_offset: Vector2 = Vector2(0, -16)

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("dummyCharacter") or body.name == "dummyCharacter":
		Global.last_checkpoint_pos = global_position + spawn_offset

		if not activated:
			activated = true
			print("Checkpoint reached!")

			var popup = get_tree().current_scene.get_node_or_null(
                "PickupUI/UIContainer/PickupDescription"
			)

			if popup:
				popup.show_pickup("CHECKPOINT!", "Respawn point updated!")
