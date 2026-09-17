extends CharacterBody2D

const BASE_SPEED = 100
var SPEED = BASE_SPEED
const JUMP_VELOCITY = -300.0

const DASH_SPEED = 350.0
var dash_limit = 1
var is_dashing = false
var dash_direction = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gc := $GrappleController

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || gc.launched):
		velocity.y += JUMP_VELOCITY
		gc.retreat()
		
	# Get the input directions: -1, 0, 1
	var direction := Input.get_axis("move left", "move right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Handle dash
	if Input.is_action_just_pressed("dash") and dash_limit > 0:
		is_dashing = true
		dash_limit = 0
		$dashTimer.start()
		
		# Saves the direction when the dash begins
		if direction != 0:
			dash_direction = direction
		else:
			dash_direction = -1.0 if animated_sprite.flip_h else 1.0
	
	# Play animations
	if is_on_floor():
		dash_limit = 1
		if direction == 0:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_dash_timer_timeout() -> void:
	is_dashing = false
