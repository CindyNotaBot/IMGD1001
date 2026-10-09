class_name Player
extends CharacterBody2D

# --- Movement Parameters ---
const COYOTE_TIME = 0.2
var coyote_timer := 0.0
var default_collision_layer: int
var default_collision_mask: int

const BASE_SPEED = 200
var SPEED = BASE_SPEED

const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 1
const MAX_LIVES = 3
var jumpCounter = MAX_JUMPS

const DASH_SPEED = 550.0
var dash_limit = 1
var is_dashing = false
var dash_direction = 1.0
var wall_jumped = false

# --- Safe Respawn Tracking ---
var last_safe_position: Vector2 = Vector2.ZERO
var position_save_timer: float = 0.0
const POSITION_SAVE_INTERVAL = 0.2

# --- Health & Economy (Static Variables) ---
const MAX_SHARDS = 8
const FULL_HEART = 4
static var health_piece = 0
static var total_health_pieces = 0

static var max_health = 3
static var current_health = max_health
static var can_double_jump = false
static var can_wall_jump = false
static var can_grapple = false
static var got_key = false

# --- Combat & State Flags ---
var can_input = true
var is_attacking = false
var can_take_damage = true

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gc := $GrappleController
@onready var player_raycast_right: RayCast2D = $player_raycast_right
@onready var player_raycast_left: RayCast2D = $player_raycast_left
@onready var wall_slide_left_raycast: RayCast2D = $wall_slide_left_raycast
@onready var wall_slide_right_raycast: RayCast2D = $wall_slide_right_raycast
@onready var attack_timer: Timer = $attack_timer
@onready var dash_particles: CPUParticles2D = $dash_particles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
@onready var sfx_dash: AudioStreamPlayer2D = $sfx_dash

# --- Visual Screen Transition Overlay ---
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay

func _ready() -> void:
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	
	if "last_checkpoint_pos" in Global and Global.last_checkpoint_pos != Vector2.ZERO:
		global_position = Global.last_checkpoint_pos

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
		
func is_on_walls() -> bool:
	return ((wall_slide_left_raycast.is_colliding() or wall_slide_right_raycast.is_colliding())
		and not is_on_floor()
		and can_wall_jump
	)

func _physics_process(delta: float) -> void:
	wall_jumped = false
	
	# Save the safe location of the player when walking stably on a floor
	if is_on_floor() and not is_dashing and can_input:
		position_save_timer += delta
		if position_save_timer >= POSITION_SAVE_INTERVAL:
			last_safe_position = global_position
			position_save_timer = 0.0
	else:
		position_save_timer = 0.0
	
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta /1.2
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
		jumpCounter = MAX_JUMPS

	# Capture core movement variables safely
	var direction := 0.0
	
	# Block player inputs completely while the fade transition or knockback locks input
	if can_input:
		direction = Input.get_axis("move left", "move right")

		# Handle jump and wall jump
		if Input.is_action_just_pressed("jump"):
			# Wall jump right wall
			if is_on_wall_right():
				velocity.y = JUMP_VELOCITY
				velocity.x = -350
				wall_jumped = true
				sfx_jump.play()

			# Wall jump left wall
			elif is_on_wall_left():
				velocity.y = JUMP_VELOCITY
				velocity.x = 350
				wall_jumped = true
				sfx_jump.play()

			# Normal ground jump or coyote jump
			elif is_on_floor() or coyote_timer > 0.0:
				velocity.y = JUMP_VELOCITY
				coyote_timer = 0.0
				jumpCounter = MAX_JUMPS
				sfx_jump.play()

			# Jump while grappling
			elif gc.launched:
				velocity.y = JUMP_VELOCITY
				gc.retreat()
				sfx_jump.play()
				
			# Double Jump
			elif jumpCounter > 0 and can_double_jump:
				velocity.y = JUMP_VELOCITY
				jumpCounter -= 1
				sfx_jump.play()
				
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= 0.5
			
		# Handle attack
		if Input.is_action_just_pressed("attack") and not is_attacking:
			is_attacking = true
			animated_sprite.play("attack")
			attack_timer.start()
			
		# Handle dash
		if Input.is_action_just_pressed("dash") and dash_limit > 0:
			is_dashing = true
			dash_limit = 0
			$dashTimer.start()
			sfx_dash.play()
			velocity.y = 0.0
			dash_particles.emitting = true
			
			# Saves the direction when the dash begins
			if direction != 0:
				dash_direction = direction
			else:
				dash_direction = -1.0 if animated_sprite.flip_h else 1.0
			
			dash_particles.direction.x = -dash_direction
	
	# Flip the sprite (keeps running even if input is locked to prevent moonwalking)
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Handle on wall slide
	if is_on_walls() and velocity.y > 0:
		velocity.y = min(velocity.y, 100.0)
		
	# Play animations
	if is_attacking:
		pass
	elif is_on_floor():
		dash_limit = 1
		if direction == 0:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")
	
	# Apply final velocity movement vectors
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0.0
	elif not wall_jumped:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# --- TileMapLayer Spike Collision Loop ---
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			var local_position = collider.to_local(collision.get_position() - collision.get_normal() * 2)
			var tile_coords = collider.local_to_map(local_position)
			
			var tile_data = collider.get_cell_tile_data(tile_coords)
			if tile_data:
				var hazard = tile_data.get_custom_data("spike_hazard")
				
				if hazard == "spikes" and can_take_damage:
					Player.current_health -= 1
					_apply_iframes(1.0)
					print("Health remaining: ", Player.current_health)
					
					# CASE A: Game Over -> Lock physics layers, trigger load screen sequence
					if Player.current_health <= 0:
						print("you died")
						Engine.time_scale = 0.5
						var death_sfx = get_node_or_null("sfx_death")
						if death_sfx:
							death_sfx.play() 
			
						set_deferred("collision_layer", 0)
						set_deferred("collision_mask", 0)
						delayed_respawn(0.5)
					
					# CASE B: Hurt but Alive -> Clean, smooth fading teleport sequence
					else:
						smooth_respawn()
						
						var hit_sfx = get_node_or_null("sfx_hit")
						if hit_sfx:
							hit_sfx.play()
						
						break # Break out immediately to escape duplicate hits in same frame

# --- Signal Connection Callbacks ---
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_particles.emitting = false
	
func _on_attack_timer_timeout() -> void:
	is_attacking = false

# --- System Functions: Respawning and Damage Logic ---
func smooth_respawn() -> void:
	if not is_inside_tree(): 
		return
		
	velocity = Vector2.ZERO
	can_input = false 
	
	# 1. Verify fade_overlay node exists before doing anything
	if has_node("CanvasLayer/FadeOverlay") and fade_overlay != null:
		var tween = create_tween()
		if tween:
			var prop_tween = tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.15)
			
			# Safety check: if tween_property failed, bypass it
			if prop_tween:
				prop_tween.set_trans(Tween.TRANS_SINE)
			
			tween.tween_callback(func():
				if last_safe_position != Vector2.ZERO:
					global_position = last_safe_position
				else:
					respawn()
			)
			
			tween.tween_interval(0.05)
			
			var fade_in_tween = tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.2)
			if fade_in_tween:
				fade_in_tween.set_trans(Tween.TRANS_SINE)
				
			tween.tween_callback(func():
				can_input = true
			)
			return # Exit smoothly, tween is handling it!
	
	#push_error("CRITICAL: 'CanvasLayer/FadeOverlay' node path not found! Teleporting instantly.")
	if last_safe_position != Vector2.ZERO:
		global_position = last_safe_position
	else:
		respawn()
	can_input = true


func respawn() -> void:
	if "last_checkpoint_pos" in Global and Global.last_checkpoint_pos != Vector2.ZERO:
		global_position = Global.last_checkpoint_pos
	else:
		var spawn_node = get_tree().current_scene.find_child("PlayerSpawn")
		if spawn_node:
			global_position = spawn_node.global_position
		else:
			get_tree().reload_current_scene()

func _apply_iframes(duration: float) -> void:
	can_take_damage = false
	if animation_player:
		animation_player.play("damage_taken")
	await get_tree().create_timer(duration).timeout
	can_take_damage = true

func delayed_respawn(delay_duration: float) -> void:
	var tree = get_tree()
	if not tree: return
	await tree.create_timer(delay_duration).timeout
	Engine.time_scale = 1.0
	Player.current_health = Player.max_health
	can_take_damage = true
	
	var loading_screen_scene = load("res://Scenes/loading_screen.tscn")
	if loading_screen_scene:
		var loading_screen_instance = loading_screen_scene.instantiate()
		
		if not is_inside_tree(): return
		get_tree().current_scene.add_child(loading_screen_instance)
		await get_tree().process_frame
		
		respawn()
		
		if not is_inside_tree(): return
		collision_layer = default_collision_layer
		collision_mask = default_collision_mask
		velocity = Vector2.ZERO
		can_input = true
		
		if is_instance_valid(loading_screen_instance):
			tree.create_timer(1.0).timeout.connect(func():
				if is_instance_valid(loading_screen_instance):
					loading_screen_instance.queue_free()
			)
		
		
#class_name Player
#extends CharacterBody2D
#
#const COYOTE_TIME = 0.2
#var coyote_timer := 0.0
#var default_collision_layer: int
#var default_collision_mask: int
#const MAX_SHARDS = 8
#const FULL_HEART = 4
#static var health_piece = 0
#static var total_health_pieces = 0
#
#const BASE_SPEED = 200
#var SPEED = BASE_SPEED
#
#const JUMP_VELOCITY = -400.0
#const MAX_JUMPS = 1
#const MAX_LIVES = 3
#var jumpCounter = MAX_JUMPS
#
#const DASH_SPEED = 550.0
#var dash_limit = 1
#var is_dashing = false
#var dash_direction = 1.0
#var wall_jumped = false
#var can_take_damage = true
#var last_safe_position: Vector2 = Vector2.ZERO
#var position_save_timer: float = 0.0
#const POSITION_SAVE_INTERVAL = 0.2
#
#static var max_health = 3
#static var current_health = max_health
#static var can_double_jump = false
#static var can_wall_jump = false
#static var can_grapple = false
#static var got_key = false
#
#var can_input = true
#var is_attacking = false
#
#
#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var gc := $GrappleController
#@onready var player_raycast_right: RayCast2D = $player_raycast_right
#@onready var player_raycast_left: RayCast2D = $player_raycast_left
#@onready var wall_slide_left_raycast: RayCast2D = $wall_slide_left_raycast
#@onready var wall_slide_right_raycast: RayCast2D = $wall_slide_right_raycast
#@onready var attack_timer: Timer = $attack_timer
#@onready var dash_particles: CPUParticles2D = $dash_particles
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
#
#
#@onready var sfx_jump: AudioStreamPlayer2D = $sfx_jump
#@onready var sfx_dash: AudioStreamPlayer2D = $sfx_dash
#
#static func pickup_vile() -> void:
	#if health_piece < FULL_HEART:
		#health_piece += 1
		#print("Health viles collected: ")
		#print(health_piece)
		#total_health_pieces += 1
		#print("total health pieces")
		#print(total_health_pieces)
#
		#if health_piece == FULL_HEART:
			#print("Health viles collected: ")
			#print(health_piece)
			#print("Collected 4 viles, adding an extra heart")
			#health_piece = 0
			#Player.max_health += 1
			#Player.current_health = Player.max_health
			#print(Player.current_health)
#
			#if total_health_pieces == MAX_SHARDS:
				#print("All viles collected!")
#
#func is_on_wall_left() -> bool:
	#if player_raycast_left.is_colliding() and not is_on_floor() and can_wall_jump:
		#return true
	#else:
		#return false
#
#func is_on_wall_right() -> bool:
	#if player_raycast_right.is_colliding() and not is_on_floor() and can_wall_jump:
		#return true
	#else:
		#return false
		#
#func is_on_walls() -> bool:
	#return ((wall_slide_left_raycast.is_colliding() or wall_slide_right_raycast.is_colliding())
		#and not is_on_floor()
		#and can_wall_jump
	#)
#
#func _physics_process(delta: float) -> void:
	#wall_jumped = false
	#
	## Save the position of the player
	#if is_on_floor() and not is_dashing:
		#position_save_timer += delta
		#if position_save_timer >= POSITION_SAVE_INTERVAL:
			#last_safe_position = global_position
			#position_save_timer = 0.0
	#else:
		#position_save_timer = 0.0
	#
	## Add the gravity.
	#if not is_on_floor() and not is_dashing:
		#velocity += get_gravity() * delta
		#coyote_timer -= delta
	#else:
		#coyote_timer = COYOTE_TIME
		#jumpCounter = MAX_JUMPS
#
	## Handle jump and wall jump
	#if Input.is_action_just_pressed("jump"):
		## Wall jump right wall
		#if is_on_wall_right():
			#velocity.y = JUMP_VELOCITY
			#velocity.x = -350
			#wall_jumped = true
			#sfx_jump.play()
#
		## Wall jump left wall
		#elif is_on_wall_left():
			#velocity.y = JUMP_VELOCITY
			#velocity.x = 350
			#wall_jumped = true
			#sfx_jump.play()
#
		## Normal ground jump
		#elif is_on_floor() or coyote_timer > 0.0:
			#velocity.y = JUMP_VELOCITY
			#coyote_timer = 0.0
			#jumpCounter = MAX_JUMPS
			#sfx_jump.play()
#
		## Jump while grappling
		#elif gc.launched:
			#velocity.y = JUMP_VELOCITY
			#gc.retreat()
			#sfx_jump.play()
		#elif jumpCounter > 0 and can_double_jump:
			## Double jump
			#velocity.y = JUMP_VELOCITY
			#jumpCounter -= 1
			#sfx_jump.play()
			#
	#if Input.is_action_just_released("jump") and velocity.y < 0:
		#velocity.y *= 0.5
		#
	## Handle attack
	#if Input.is_action_just_pressed("attack") and not is_attacking:
		#is_attacking= true
		#animated_sprite.play("attack")
		#attack_timer.start()
		#
	## Get the input directions: -1, 0, 1
	#var direction := Input.get_axis("move left", "move right")
	#
	## Flip the sprite
	#if direction > 0:
		#animated_sprite.flip_h = false
	#elif direction < 0:
		#animated_sprite.flip_h = true
		#
	## Handle on wall slide
	#if is_on_walls() and velocity.y > 0:
		#velocity.y = min(velocity.y, 100.0)
		#
	## Handle dash
	#if Input.is_action_just_pressed("dash") and dash_limit > 0:
		#is_dashing = true
		#dash_limit = 0
		#$dashTimer.start()
		#sfx_dash.play()
		#velocity.y = 0.0
		#dash_particles.emitting = true
		#
		## Saves the direction when the dash begins
		#if direction != 0:
			#dash_direction = direction
		#else:
			#dash_direction = -1.0 if animated_sprite.flip_h else 1.0
			#dash_particles.direction.x = -dash_direction
	#
	## Play animations
	#if is_attacking:
		#pass
		#
	## Play animations
	#elif is_on_floor():
		#dash_limit = 1
		#if direction == 0:
			#animated_sprite.play("idle")
	#else:
		#animated_sprite.play("jump")
	#
	## Apply movement
	#if is_dashing:
		#velocity.x = dash_direction * DASH_SPEED
		#velocity.y = 0.0
	#elif not wall_jumped:
		#if direction:
			#velocity.x = direction * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
	#
	#for i in range(get_slide_collision_count()):
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#
		#if collider is TileMapLayer:
			#var local_position = collider.to_local(collision.get_position() - collision.get_normal() * 2)
			#var tile_coords = collider.local_to_map(local_position)
			#
			#var tile_data = collider.get_cell_tile_data(tile_coords)
			#if tile_data:
				#var hazard = tile_data.get_custom_data("spike_hazard")
				#
				#if hazard == "spikes" and can_take_damage:
					#Player.current_health -= 1
					#_apply_iframes(1.0)
					#print("Health remaining: ", Player.current_health)
					#
					#if Player.current_health <= 0:
						#print("you died")
						#Engine.time_scale = 0.5
						#var death_sfx = get_node_or_null("sfx_death")
						#if death_sfx:
							#death_sfx.play() 
			#
						#set_deferred("collision_layer", 0)
						#set_deferred("collision_mask", 0)
						#delayed_respawn(0.5)
					#
					#else:
						#velocity = Vector2.ZERO 
						#
						#if last_safe_position != Vector2.ZERO:
							#global_position = last_safe_position
						#else:
							#respawn()
						#
						#var hit_sfx = get_node_or_null("sfx_hit")
						#if hit_sfx:
							#hit_sfx.play()
						#
						#break
							#
#func _on_dash_timer_timeout() -> void:
	#is_dashing = false
	#dash_particles.emitting = false
	#
#func _on_attack_timer_timeout() -> void:
	#is_attacking = false
#
#func _ready() -> void:
	#default_collision_layer = collision_layer
	#default_collision_mask = collision_mask
	#
	#if Global.last_checkpoint_pos != Vector2.ZERO:
		#global_position = Global.last_checkpoint_pos
		#
#func respawn() -> void:
	#if Global.last_checkpoint_pos != Vector2.ZERO:
		#global_position = Global.last_checkpoint_pos
	#else:
		#var spawn_node = get_tree().current_scene.find_child("PlayerSpawn")
		#if spawn_node:
			#global_position = spawn_node.global_position
		#else:
			#get_tree().reload_current_scene()
			#return
#
#func _apply_iframes(duration: float) -> void:
	#can_take_damage = false
	#animation_player.play("damage_taken")
	#await get_tree().create_timer(duration).timeout
	#can_take_damage = true
#
#func delayed_respawn(delay_duration: float) -> void:
	#var tree = get_tree()
	#if not tree: return
	#
	#await tree.create_timer(delay_duration).timeout
	#
	#Engine.time_scale = 1.0
	#Player.current_health = Player.max_health
	#
	#var loading_screen_scene = load("res://Scenes/loading_screen.tscn")
	#if loading_screen_scene:
		#var loading_screen_instance = loading_screen_scene.instantiate()
		#
		#if not is_inside_tree(): return
		#get_tree().current_scene.add_child(loading_screen_instance)
		#await get_tree().process_frame
		#
		#respawn()
		#
		#if not is_inside_tree(): return
		#
		#collision_layer = default_collision_layer
		#collision_mask = default_collision_mask
		#velocity = Vector2.ZERO
		#
		#await tree.create_timer(1.0).timeout
		#
		#if is_instance_valid(loading_screen_instance):
			#loading_screen_instance.queue_free()
