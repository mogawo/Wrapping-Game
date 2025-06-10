extends CharacterBody3D


@export var GROUND_SPEED = 5.0
@export var AIR_SPEED = 10
@export var JUMP_VELOCITY = 4.5
@export_range(0.0, 1.0) var MOUSE_SENSITIITY = 0.002
@export var TILT_LIMIT = deg_to_rad(75)
@export var BULLET = preload("res://bullet.tscn")
@export var MASS = 1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, direction.x * GROUND_SPEED, 10)
		velocity.z = move_toward(velocity.z, direction.z * GROUND_SPEED, 10)
	else:
		velocity.x += direction.x * AIR_SPEED * delta
		velocity.z += direction.z * AIR_SPEED * delta
	
	move_and_slide()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if $CameraPivot/GunLeft/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunLeft/Gunpoint/Bullet.queue_free()
		else:
			spawn_bullet($CameraPivot/GunLeft/Gunpoint)
			
	if event.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if $CameraPivot/GunRight/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunRight/Gunpoint/Bullet.queue_free()
		else:
			spawn_bullet($CameraPivot/GunRight/Gunpoint)

	if event.is_action_pressed("reel_in_left"):
		if $CameraPivot/GunLeft/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunLeft/Gunpoint/Bullet.reel_in()
	if event.is_action_released("reel_in_left"):
		if $CameraPivot/GunLeft/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunLeft/Gunpoint/Bullet.reel_stop()
			
	if event.is_action_pressed("reel_in_right"):
		if $CameraPivot/GunRight/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunRight/Gunpoint/Bullet.reel_in()
	if event.is_action_released("reel_in_right"):
		if $CameraPivot/GunRight/Gunpoint.get_node_or_null("Bullet"):
			$CameraPivot/GunRight/Gunpoint/Bullet.reel_stop()
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$CameraPivot.rotation.x -= event.relative.y * MOUSE_SENSITIITY
		$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, -TILT_LIMIT, TILT_LIMIT)
		self.rotation.y = clampf(self.rotation.y - event.relative.x * MOUSE_SENSITIITY, -TAU, TAU)

func spawn_bullet(gunpoint: Node3D):
	var bullet = BULLET.instantiate()
	gunpoint.add_child(bullet)
	bullet.fire()
	bullet.draw_wraps(true)
	
		
