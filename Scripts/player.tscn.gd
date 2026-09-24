extends CharacterBody2D

const BASE_SPEED = 3000.0
var SPEED = BASE_SPEED
const JUMP_VELOCITY = -300.0

var dash_limit = 1

# Jump settings
const MAX_JUMPS = 2
var jumpCounter = 0

# Lives
const MAX_LIVES = 3
var lives = MAX_LIVES

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		#velocity.y += get_gravity() * delta

	# Reset jump counter when we land
	if is_on_floor():
		jumpCounter = 0
		dash_limit = 1

	# Handle jump / double jump
	if Input.is_action_just_pressed("jump"):
		if jumpCounter < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY 
			jumpCounter += 1

	# Get the input directions: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


	# Handle dash
	if Input.is_action_just_pressed("dash"):
		if dash_limit > 0:
			$dashTimer.start()
			SPEED *= 10
			dash_limit = 0

	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply movement
	if direction:
		velocity.x = direction * BASE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()


func _on_dash_timer_timeout() -> void:
	SPEED = BASE_SPEED
