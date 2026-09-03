extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# When start button is pressed screen is changed to the game screen
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

# When version notes button is pressed screen is changed to version notes screen
func _on_version_notes_pressed():
	get_tree().change_scene_to_file("res://Scenes/version_notes.tscn")

# When credits button is pressed screen is changed to credits screen
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
