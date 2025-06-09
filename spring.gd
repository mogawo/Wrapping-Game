extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func handle_grapple(delta: float) -> void:
	if tail is not CharacterBody3D:
		print("Parent of ChainLink is not of CharacterBody3D")
		return
	var player := PLAYER
	var target_dir = player.position.direction_to(position)
	var target_dist = player.position.distance_to(position)
	var displacement = target_dist - REST_LENGTH
	
	var force := Vector3.ZERO
	if displacement > 0:
		var spring_force_magnitude = STIFFNESS * displacement
		var spring_force = target_dir * spring_force_magnitude
		var vel_dot = player.velocity.dot(target_dir)
		var vert_damping = -DAMPING * vel_dot * target_dir
		var hori_damping = -player.velocity / 2
		force = spring_force + vert_damping + hori_damping
	player.velocity += force * delta
