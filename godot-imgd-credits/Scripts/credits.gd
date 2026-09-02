extends Control


var scroll_speed: float = 100.0

@onready var credits_container: VBoxContainer = $CreditsContainer

var finished: bool = false

func _ready():
	credits_container.position.y = get_viewport_rect().size.y

func _process(delta):
	if finished:
		return
	
	
	credits_container.position.y -= scroll_speed * delta
	
	if credits_container.position.y + credits_container.size.y < 0:
		finish_credits()

func finish_credits():
	if not finished:
		finished = true
