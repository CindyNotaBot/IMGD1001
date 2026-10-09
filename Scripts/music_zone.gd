extends Area2D

@onready var music_player: AudioStreamPlayer = $MusicNew

@export var fade_duration: float = 1.5
@export var target_volume_db: float = 0.0
@export var play_on_start: bool = false

var has_played_intro: bool = false
var tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var current_track_path = music_player.stream.resource_path
	
	# Restores music smoothly across deaths
	if Global.saved_music_track == current_track_path and Global.saved_music_position > 0.05:
		music_player.volume_db = target_volume_db
		has_played_intro = true
		await get_tree().process_frame
		music_player.play(Global.saved_music_position)
		Global.saved_music_position = 0.0
		Global.saved_music_track = ""
	elif play_on_start:
		music_player.volume_db = target_volume_db
		has_played_intro = true
		await get_tree().process_frame 
		if not music_player.playing:
			music_player.play()
	else:
		music_player.volume_db = -80.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter":
		if tween: tween.kill() 
		
		if not music_player.playing:
			music_player.play() # Let Godot handle the loop/intro natively!
		
		tween = create_tween()
		tween.tween_property(music_player, "volume_db", target_volume_db, fade_duration)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "dummyCharacter":
		if tween: tween.kill()
		
		tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(music_player.stop)
		
func save_music_state_before_death() -> void:
	if music_player and music_player.playing:
		Global.saved_music_track = music_player.stream.resource_path
		Global.saved_music_position = music_player.get_playback_position()
