
extends Panel

@onready var title_label: Label = $VBoxContainer/Title
@onready var description_label: Label = $VBoxContainer/Description

var popup_timer: Timer

func _ready() -> void:
	hide()

	popup_timer = Timer.new()
	popup_timer.one_shot = true
	add_child(popup_timer)
	popup_timer.timeout.connect(hide)

func show_pickup(title_text: String, description_text: String) -> void:
	title_label.text = title_text
	description_label.text = description_text

	# Set popup size
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = Vector2(600, 130)

	# Position at bottom center of screen
	var screen_size = get_viewport_rect().size
	position = Vector2(
		(screen_size.x - size.x) / 2.0,
		screen_size.y - size.y - 150.0
	)

	show()
	popup_timer.start(4.0)
