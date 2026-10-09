extends Node

var last_checkpoint_pos: Vector2 = Vector2.ZERO

var saved_music_track: String = ""
var saved_music_position: float = 0.0

func _ready() -> void:
	last_checkpoint_pos = Vector2.ZERO
	saved_music_track = ""
	saved_music_position = 0.0
