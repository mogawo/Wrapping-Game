extends RigidBody3D

@export var SPEED = 50
@export var DRAW_LINE := true
@export var COLOR: Color
@export var REEL_STEP := 0.01
@export var SLACK := 100

var SHOOT = false

var ATTACHED := false

var REEL_DIR := 0

var STIFFNESS := 1000
var REST_LENGTH := 0
var DAMPING := 100

var PLAYER: CharacterBody3D
var TARGET: Node3D
var ATTACH_POINT: Vector3

@export var ROPE_GIRTH = 0.1





#Will draw chain_link from self to parent
@onready var chain_link: ChainLink = $ChainLink
@onready var head := chain_link
@onready var tail := get_parent() 
var draw := false
func _ready() -> void:
	self.set_as_top_level(true)


func _physics_process(delta: float) -> void:
	if REEL_DIR:
		REST_LENGTH = lerpf(REST_LENGTH, 0, REEL_STEP)
	if draw and ATTACHED:
		#update_line(ATTACH_POINT, TARGET.global_position, COLOR)
		update_cast(ATTACH_POINT)
		update_forward_cast()
	if not ATTACHED:
		ATTACH_POINT = global_position
	if head and tail:
		handle_grapple(delta)
		

func draw_chains(enable = false):
	create_line()
	create_rope_cast()
	draw = enable

#TODO make new class or merge with ChainLink
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

func reel_in():
	REEL_DIR = 1
func reel_stop():
	REEL_DIR = 0
func reel_out():
	REEL_DIR = -1
	

func fire():
	apply_central_impulse(-transform.basis.z * SPEED)

func create_line(origin = null):
	var rope = MeshInstance3D.new()
	$RopeMesh.add_child(rope)
	rope.mesh = ImmediateMesh.new()
	if origin:
		ATTACH_POINT = origin

func update_line(pos1: Vector3, pos2: Vector3, color):
	var parts_count = $RopeMesh.get_child_count()
	var rope_part: Node3D
	if parts_count > 0:
		rope_part = $RopeMesh.get_child(parts_count-1)
	if rope_part:
		var material = ORMMaterial3D.new()
		rope_part.mesh = ImmediateMesh.new()
		rope_part.mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES, material)
		rope_part.mesh.surface_add_vertex(pos1)
		rope_part.mesh.surface_add_vertex(pos2)
		rope_part.mesh.surface_end()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
	
func update_forward_cast():
	$ForwardCast.global_position = TARGET.global_position
	$ForwardCast.target_position = ATTACH_POINT - TARGET.global_position		
		

func create_rope_cast(origin = null):
	var rope_cast = RayCast3D.new()
	rope_cast.top_level = true
	$RopeCast.add_child(rope_cast)
	rope_cast.hit_back_faces = true
	rope_cast.hit_from_inside = false
	rope_cast.set_collision_mask_value(1, false)
	rope_cast.set_collision_mask_value(2, true)
	rope_cast.set_collision_mask_value(3, true)
	rope_cast.add_exception(self)
	rope_cast.enabled = true
	if origin:
		rope_cast.global_position = origin
		ATTACH_POINT = origin

func update_cast(pos: Vector3):
	var casts_count = $RopeCast.get_child_count()
	var cast_part: RayCast3D
	if casts_count > 0:
		cast_part = $RopeCast.get_child(casts_count-1)
		cast_part.global_position = ATTACH_POINT
	if cast_part and cast_part.global_position != TARGET.global_position:
		cast_part.target_position = TARGET.global_position - ATTACH_POINT
	if cast_part and cast_part.is_colliding():
		var contact_point = cast_part.get_collision_point()
		var contact_normal_back = cast_part.get_collision_normal()
		var contact_normal_forward = Vector3.ZERO
		$ForwardCast.force_raycast_update()
		if $ForwardCast.is_colliding():
			contact_normal_forward = $ForwardCast.get_collision_normal()
			draw_contact_point($ForwardCast.get_collision_point(), Color.BLUE)
		contact_point += (contact_normal_back + contact_normal_forward) * 0.1
		draw_contact_point(contact_point, Color.GREEN)
		create_rope_cast(contact_point)
		
		chain_link.update_end_link(pos, contact_point)
		chain_link.add_link()
		#update_line(pos, contact_point, Color.AQUA)
		#create_line(contact_point)


func _on_body_entered(body: Node) -> void:
	if body is not CharacterBody3D:
		self.linear_velocity = Vector3.ZERO
		self.angular_velocity = Vector3.ZERO
		REST_LENGTH = head.global_position.distance_to(tail.global_position) + SLACK
		ATTACHED = true
		ATTACH_POINT = $RopeCast.global_position
		
func draw_contact_point(pos: Vector3, color: Color):
	var waypoint = MeshInstance3D.new()
	waypoint.set_as_top_level(true)
	waypoint.name = "WAYPOINT"
	add_child(waypoint)
	waypoint.global_position = Vector3.ZERO
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	waypoint.mesh = ImmediateMesh.new()
	waypoint.mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES, material)
	waypoint.mesh.surface_add_vertex(pos)
	waypoint.mesh.surface_add_vertex(pos + Vector3.UP * 100)
	waypoint.mesh.surface_end()

	
