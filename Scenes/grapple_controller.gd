extends Node2D 

@export var rest_length = 2.0
@export var stiffness = 20.0
@export var damping= 2.0
@export var max_grapple_time = 2.0

@onready var player := get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D
@onready var sfx_grapple: AudioStreamPlayer2D = $"../sfx_grapple"

var launched = false
var target: Vector2 
var grapple_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ray.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("grapple") and player.can_grapple:
		launch()
	if Input.is_action_just_released("grapple"):
		retreat()
		
	if launched:
		grapple_time += delta
		
		if grapple_time >= max_grapple_time:
			retreat()
		else:
			handle_grapple(delta)
		
func launch():
	if ray.is_colliding():
		var collider = ray.get_collider()
		var collision_point = ray.get_collision_point()
		
		# does not allow to grapple if it's off-screen
		if not is_point_in_view(collision_point):
			return
			
		# Grabs and pulls enemy towards player
		if collider.is_in_group("enemy"):
			return

		launched = true
		grapple_time = 0.0
		target = ray.get_collision_point()
		rope.show()
		sfx_grapple.play()
	
func retreat():
	launched = false
	rope.hide()

func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	if target_distance < 25.0:
		retreat()
		return
	
	var displacement = target_distance - rest_length
	
	var force = Vector2.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_direction * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_direction)
		var damping_force = -damping * vel_dot * target_direction
		
		force = spring_force + damping_force
	
	player.velocity += force * delta
	update_rope()

func update_rope():
	var end_point = to_local(target)
	var segments = 12
	
	rope.clear_points()
	
	for i in range(segments + 1):
		var t = float(i) / segments
		
		var point = Vector2.ZERO.lerp(end_point, t)

		var direction = end_point.normalized()
		var perpendicular = Vector2(-direction.y, direction.x)
		
		var wave = sin(t * PI * 3.0 + Time.get_ticks_msec() * 0.008)
		var wave_strength = sin(t * PI) * 6.0
		
		point += perpendicular * wave * wave_strength
		
		rope.add_point(point)

func is_point_in_view(global_point: Vector2) -> bool:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		var screen_rect = get_viewport().get_visible_rect()
		return screen_rect.has_point(global_point)
		
	var screen_center = camera.get_screen_center_position()
	var viewport_size = get_viewport().get_visible_rect().size / camera.zoom
	
	# Calculate the boundaries of the camera in the world
	var half_size = viewport_size * 0.5
	var min_bound = screen_center - half_size
	var max_bound = screen_center + half_size
	
	return global_point.x >= min_bound.x and global_point.x <= max_bound.x and \
		   global_point.y >= min_bound.y and global_point.y <= max_bound.y
