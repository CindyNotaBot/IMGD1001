extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# When back  button is pressed screen is changed to the main menu
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
