extends CharacterBody2D

var speed = 40.0
var patrol_speed = 30.0
var patrol_distance = 100.0

var player_chase = false
var player = null

var direction = 1
var start_x
var start_y

func _ready():
	start_x = position.x
	start_y = position.y

func _physics_process(delta):
	if player_chase and player != null:
		var player_direction = sign(player.global_position.x - global_position.x)
		velocity.x = player_direction * speed
	else:
		if position.x >= start_x + patrol_distance:
			direction = -1
		elif position.x <= start_x - patrol_distance:
			direction = 1

		velocity.x = direction * patrol_speed

	velocity.y = 0
	move_and_slide()
	position.y = start_y

func _on_detection_area_body_entered(body: Node2D):
	if body.name == "dummyCharacter":
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D):
	if body == player:
		player = null
		player_chase = false
