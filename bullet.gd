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
@onready var spring: Spring = $Spring
@onready var wrap_cast: WrapCast = $WrapCast
@onready var head := chain_link
@onready var tail := get_parent() 



var draw := false
func _ready() -> void:
	self.set_as_top_level(true)
	#print(tail)
	#spring.grappler = tail


func _physics_process(delta: float) -> void:
	if draw and ATTACHED:
		chain_link.update_end_link(ATTACH_POINT, tail.global_position)
		wrap_cast.update_last_cast(tail.global_position)
		#draw_contact_point(ATTACH_POINT, Color.RED)
		#draw_contact_point(tail.global_position, Color.GREEN)
	if not ATTACHED:
		ATTACH_POINT = spring.global_position
		

func draw_chains(enable = false):
	chain_link.add_link()
	wrap_cast.add_ray_cast()
	draw = enable
	

func fire():
	apply_central_impulse(-transform.basis.z * SPEED)
	
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
		#REST_LENGTH = head.global_position.distance_to(tail.global_position) + SLACK
		ATTACHED = true
		#ATTACH_POINT = $RopeCast.global_position
		spring.rest_length = head.global_position.distance_to(tail.global_position) + SLACK
		spring.attach_point = head.global_position
		
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

	
