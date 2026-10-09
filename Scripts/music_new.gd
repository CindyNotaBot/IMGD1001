#extends Area2D
#
#@onready var music_player: AudioStreamPlayer = $MusicPlayer
#
#@export var fade_duration: float = 1.5
#@export var target_volume_db: float = 0.0
#
#var tween: Tween
#
#func _ready() -> void:
	#music_player.volume_db = -80.0 
	#
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.name == "dummyCharacter":
		#if tween: tween.kill() 
	#
		#if not music_player.playing:
			#music_player.play()
			#
		#tween = create_tween()
		#tween.tween_property(music_player, "volume_db", target_volume_db, fade_duration)
#
#func _on_body_exited(body: Node2D) -> void:
	#if body.name == "dummyCharacter":
		#if tween: tween.kill()
		#
		#tween = create_tween()
		#tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		#
		#tween.tween_callback(music_player.stop)
