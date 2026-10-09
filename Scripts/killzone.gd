extends Area2D

@onready var timer: Timer = $Timer
@onready var sfx_death: AudioStreamPlayer2D = $sfx_death

func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter":
			Engine.time_scale = 0.5
			for node in get_tree().current_scene.get_children():
				if "MusicZone" in node.name and node.has_node("MusicNew"):
					var audio_player = node.get_node("MusicNew")
					if audio_player.playing:
						Global.saved_music_track = audio_player.stream.resource_path
						Global.saved_music_position = audio_player.get_playback_position()
						print("Successfully intercepted music! Saved position: ", Global.saved_music_position)
						break 
			var death_sfx = body.get_node_or_null("sfx_death")
			if death_sfx:
				death_sfx.play() 
				
			body.set_deferred("collision_layer", 0)
			body.set_deferred("collision_mask", 0)
			body.delayed_respawn(0.5)
			
		#print("you died")
	#
		#var death_sfx = body.get_node_or_null("sfx_death")
		#if death_sfx:
			#death_sfx.play() 
	#
		#Engine.time_scale = 0.5
		#
		#var collision = body.get_node_or_null("CollisionShape2D")
		#if collision:
			#collision.queue_free()
		#
		#timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
