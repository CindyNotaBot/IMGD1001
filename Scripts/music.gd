extends AudioStreamPlayer2D

@export var loop_start_time: float = 6.0
@export var loop_end_time: float = 51.0

func _ready():
	play()

func _process(_delta):
	if playing and get_playback_position() >= loop_end_time:
		seek(loop_start_time)
