extends Node2D 

@export var rest_length = 2.0
@export var stiffness = 25.0
@export var damping= 2.0

@onready var player := get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D

var launched = false
var target: Vector2 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ray.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("grapple"):
		launch()
	if Input.is_action_just_released("grapple"):
		retreat()
		
	if launched:
		handle_grapple(delta)
		
func launch():
	if ray.is_colliding(): 
		launched = true
		target = ray.get_collision_point()
		rope.show()
	
func retreat():
	launched = false
	rope.hide()

func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	var displacement = target_distance - rest_length
	
	var force = Vector2.ZERO
	
	if displacement > 0 :
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_direction * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_direction)	
		var damping_force = -damping * vel_dot * target_direction
		
		force = spring_force + damping_force
	
	player.velocity += force * delta
	update_rope()

func update_rope():
	rope.set_point_position(1, to_local(target))
