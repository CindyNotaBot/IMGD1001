extends Area2D

const MAX_HEALTH = 5
@onready var timer: Timer = $Timer
@onready var sfx_death: AudioStreamPlayer2D = $sfx_death
var can_take_damage = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "dummyCharacter" and can_take_damage:
		Player.current_health -= 2
		body.animation_player.play("damage_taken")
		_apply_iframes(1.0)
		if Player.current_health > 0:
			print(Player.current_health)
		if Player.current_health <= 0:
			print("you died")
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
				
func _apply_iframes(duration: float) -> void:
	can_take_damage = false
	await get_tree().create_timer(duration).timeout
	can_take_damage = true
		
		


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	Player.current_health = Player.max_health
	get_tree().reload_current_scene()
