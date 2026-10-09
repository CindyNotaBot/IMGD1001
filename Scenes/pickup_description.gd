extends Panel

@onready var title: Label = $TextContainer/Title

func _ready() -> void:
	hide()

func show_pickup(title_text: String) -> void:
	title.text = title_text
	show()

	await get_tree().create_timer(4.0).timeout
	hide()
