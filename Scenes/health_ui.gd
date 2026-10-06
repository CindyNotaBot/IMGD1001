extends CanvasLayer

@onready var heart1: Label = $VBoxContainer/HeartsContainer/Heart1
@onready var heart2: Label = $VBoxContainer/HeartsContainer/Heart2
@onready var heart3: Label = $VBoxContainer/HeartsContainer/Heart3
@onready var heart4: Label = $VBoxContainer/HeartsContainer/Heart4
@onready var heart5: Label = $VBoxContainer/HeartsContainer/Heart5
@onready var vial_progress: Label = $VBoxContainer/VialProgress

func _process(delta: float) -> void:
	update_hearts()
	update_vials()

func update_hearts() -> void:
	heart1.text = "♥" if Player.current_health >= 1 else "♡"
	heart2.text = "♥" if Player.current_health >= 2 else "♡"
	heart3.text = "♥" if Player.current_health >= 3 else "♡"
	heart4.text = "♥" if Player.current_health >= 4 else "♡"
	heart5.text = "♥" if Player.current_health >= 5 else "♡"

func update_vials() -> void:
	vial_progress.text = "Vials: " + str(Player.health_piece) + " / 4"
