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





#Will draw wrap_link from self to parent
@onready var wrap_mesh: WrapMesh = $WrapMesh
@onready var spring: Spring = $Spring
@onready var wrap_cast: WrapCast = $WrapCast
@onready var head := wrap_mesh
@onready var tail := get_parent() 



var draw := false
func _ready() -> void:
	self.set_as_top_level(true)


func _physics_process(delta: float) -> void:
	if draw:
		wrap_cast.update_last_cast(tail.global_position)
		wrap_mesh.update_last_wrap(wrap_cast.from, tail.global_position)
		if wrap_cast.cast_array.size() < wrap_mesh.wrap_meshes.size():
			wrap_mesh.wrap_meshes.pop_back().queue_free()
		

func draw_wraps(enable = false):
	wrap_mesh.add_wrap_mesh()
	wrap_cast.add_wrap_cast()
	draw = enable
	

func fire():
	apply_central_impulse(-transform.basis.z * SPEED)
	

func _on_body_entered(body: Node) -> void:
	if body is not CharacterBody3D:
		self.linear_velocity = Vector3.ZERO
		self.angular_velocity = Vector3.ZERO
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

	
