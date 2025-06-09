extends Node3D
class_name Spring

@export var grappler: CharacterBody3D
@export var attach_point: Vector3

@export var stiffness := 1000
@export var rest_length := 0
@export var damping := 100
@export var reel_step := 0.01


var reel_direction
enum ReelDirection {
	EXTEND = 1,
	NONE = 0,
	RETRACT = -1
}

func reel(direction := ReelDirection.NONE):
	reel_direction = direction


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func _physics_process(delta: float) -> void:
	if reel_direction:
		rest_length = lerpf(rest_length, 0, reel_step)


func handle_grapple(delta: float) -> void:
	var target_dir = grappler.global_position.direction_to(global_position)
	var target_dist = grappler.global_position.distance_to(global_position)
	var displacement = target_dist - rest_length
	
	var force := Vector3.ZERO
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		var vel_dot = grappler.velocity.dot(target_dir)
		var vert_damping = -damping * vel_dot * target_dir
		var hori_damping = -grappler.velocity / 2
		force = spring_force + vert_damping + hori_damping
	grappler.velocity += force * delta
