class_name Player
extends CharacterBody2D

const MAX_SHARDS = 8
const FULL_HEART = 4
static var health_piece = 0
static var total_health_pieces = 0

const BASE_SPEED = 200
var SPEED = BASE_SPEED

const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 1
const MAX_LIVES = 3
var jumpCounter = MAX_JUMPS

const DASH_SPEED = 450.0
var dash_limit = 1
var is_dashing = false
var dash_direction = 1.0
var wall_jumped = false
static var max_health = 3
static var current_health = max_health
static var can_double_jump = false
static var can_wall_jump = false

static var got_key = false

var can_input = true
var is_attacking = false


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gc := $GrappleController
@onready var player_raycast_right: RayCast2D = $player_raycast_right
@onready var player_raycast_left: RayCast2D = $player_raycast_left
@onready var wall_slide_left_raycast: RayCast2D = $wall_slide_left_raycast
@onready var wall_slide_right_raycast: RayCast2D = $wall_slide_right_raycast
@onready var attack_timer: Timer = $attack_timer

@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_dash: AudioStreamPlayer2D = $sfx_dash

static func pickup_vile() -> void:
	if health_piece < FULL_HEART:
		health_piece += 1
		print("Health viles collected: ")
		print(health_piece)
		total_health_pieces += 1
		print("total health pieces")
		print(total_health_pieces)
		if health_piece == FULL_HEART:
			print("Health viles collected: ")
			print(health_piece)
			print("Collected 4 viles, adding an extra heart")
			health_piece = 0
			Player.max_health += 1
			Player.current_health = Player.max_health
			print(Player.current_health)
			if total_health_pieces == MAX_SHARDS:
				print("All viles collected!")

func is_on_wall_left() -> bool:
	if player_raycast_left.is_colliding() and not is_on_floor() and can_wall_jump:
		return true
	else:
		return false

func is_on_wall_right() -> bool:
	if player_raycast_right.is_colliding() and not is_on_floor() and can_wall_jump:
		return true
	else:
		return false
		
func is_on_walls():
	if (wall_slide_left_raycast.is_colliding() or wall_slide_right_raycast.is_colliding()) and not is_on_floor() and can_wall_jump:
		return true
	else:
		return false 
		

func _physics_process(delta: float) -> void:
	wall_jumped = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || gc.launched):
		velocity.y += JUMP_VELOCITY
		gc.retreat()
		sfx_jump.play()
	elif Input.is_action_just_pressed("jump") and jumpCounter != 0 and can_double_jump:
		velocity.y += JUMP_VELOCITY
		jumpCounter -= 1
		sfx_jump.play()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpCounter = MAX_JUMPS
		velocity.y = JUMP_VELOCITY
		sfx_jump.play()
		
		# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking= true
		animated_sprite.play("attack")
		animation_player.play("attack")
		attack_timer.start()
		
	# Get the input directions: -1, 0, 1
	var direction := Input.get_axis("move left", "move right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# handle on wall slide
	if is_on_walls() and velocity.y > 0:
		velocity.y = min(velocity.y, 100.0)
			
	# handle wall jump right
	if Input.is_action_just_pressed("jump") and Input.is_action_pressed("move left") and is_on_wall_right():
		velocity.y = -400
		velocity.x = -350
		wall_jumped = true
		sfx_jump.play()
		
	# hadle wall jump left
	if Input.is_action_just_pressed("jump") and Input.is_action_pressed("move right") and is_on_wall_left():
		velocity.y = -400
		velocity.x = 350
		wall_jumped = true
		sfx_jump.play()
		
	# Handle dash
	if Input.is_action_just_pressed("dash") and dash_limit > 0:
		is_dashing = true
		dash_limit = 0
		$dashTimer.start()
		sfx_dash.play()
		
		# Saves the direction when the dash begins
		if direction != 0:
			dash_direction = direction
		else:
			dash_direction = -1.0 if animated_sprite.flip_h else 1.0
	
	# Play animations
	if is_attacking:
		pass
		
	# Play animations
	elif is_on_floor():
		dash_limit = 1
		if direction == 0:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	elif not wall_jumped:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	
	


func _on_attack_timer_timeout() -> void:
	is_attacking = false
