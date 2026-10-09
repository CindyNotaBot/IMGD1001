extends Control

@onready var scroll_container: ScrollContainer = $Panel/ScrollContainer

var scroll_speed: float = 25.0
var scroll_position: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_position = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_position += scroll_speed * delta
	scroll_container.scroll_vertical = int(scroll_position)
	
	if scroll_position >= scroll_container.get_v_scroll_bar().max_value - scroll_container.get_v_scroll_bar().page:
		scroll_position = 0.0
		scroll_container.scroll_vertical = 0

# When back  button is pressed screen is changed to the main menu
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
