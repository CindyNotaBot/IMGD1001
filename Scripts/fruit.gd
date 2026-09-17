extends Area2D

#@onready var game_manager = %GameManager

func _on_body_entered(body):
	if SlimeHitBox.lives < 5:
		SlimeHitBox.lives += 1
	else:
		print("Max Lives have been reached")
	print(SlimeHitBox.lives)


#example code
