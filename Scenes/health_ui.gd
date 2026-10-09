extends CanvasLayer

@onready var heart1: Label = $VBoxContainer/HeartsContainer/Heart1
@onready var heart2: Label = $VBoxContainer/HeartsContainer/Heart2
@onready var heart3: Label = $VBoxContainer/HeartsContainer/Heart3
@onready var heart4: Label = $VBoxContainer/HeartsContainer/Heart4
@onready var heart5: Label = $VBoxContainer/HeartsContainer/Heart5
@onready var vial_progress: Label = $VBoxContainer/VialProgress
@onready var key_indicator: Label = $VBoxContainer/KeyIndicator

func _process(delta: float) -> void:
	update_hearts()
	update_vials()
	update_key()

func update_hearts() -> void:
	heart1.text = "♥" if Player.current_health >= 1 else "♡"
	heart2.text = "♥" if Player.current_health >= 2 else "♡"
	heart3.text = "♥" if Player.current_health >= 3 else "♡"
	heart4.text = "♥" if Player.current_health >= 4 else "♡"
	heart5.text = "♥" if Player.current_health >= 5 else "♡"

func update_vials() -> void:
	vial_progress.text = "Vials: " + str(Player.health_piece) + " / 4"
	
func update_key() -> void:
	if Player.got_key:
		key_indicator.text = "Key: Collected"
	else:
		key_indicator.text = "Key: Not Collected"
