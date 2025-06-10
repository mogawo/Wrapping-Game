extends Node3D
class_name WrapCast

var cast_array: Array[RayCast3D]
var from: Vector3

@export_range(0,1) var padding = 0.1
@onready var back_cast := $BackCast
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func add_wrap_cast():
	var forward_cast = RayCast3D.new()
	cast_array.append(forward_cast)
	forward_cast.top_level = true
	forward_cast.hit_from_inside = false
	forward_cast.hit_back_faces = false
	forward_cast.debug_shape_custom_color = Color.ORANGE
	forward_cast.debug_shape_thickness = 5
	forward_cast.set_collision_mask_value(1, false)
	forward_cast.set_collision_mask_value(2, true)
	forward_cast.set_collision_mask_value(3, true)
	add_child(forward_cast)
	
	if from.length() == 0:
		from = global_position
	
func update_last_cast(to: Vector3):
	if cast_array.size() == 1:
		from = global_position
	var last_cast = cast_array.back() as RayCast3D
	
	last_cast.global_position = from
	last_cast.target_position = to - from
	
	back_cast.global_position = to
	back_cast.target_position = from - to
	check_unwrap(to)
	if last_cast.is_colliding() and back_cast.is_colliding():
		var contact_front = last_cast.get_collision_point()
		var contact_back = back_cast.get_collision_point()
		
		var mid_point = (contact_front + contact_back) / 2
		
		var normal_front = last_cast.get_collision_normal()
		var normal_back = back_cast.get_collision_normal()
		
		var mid_normal = (normal_back + normal_front) * padding
		from = mid_point + mid_normal
		
		
		add_wrap_cast()
		#draw_waypoint(contact_front, Color.RED)
		#draw_waypoint(contact_back, Color.GREEN$
	
var unwrap_point: Vector3
func check_unwrap(to: Vector3):
	var array_size = cast_array.size() 
	if array_size < 2:
		return false
	var before_last_cast = cast_array[array_size - 2]
	var last_target_pos = before_last_cast.target_position
	before_last_cast.target_position = to - before_last_cast.global_position
	if not before_last_cast.is_colliding() and unwrap_point.distance_squared_to(from) < 1:
		cast_array.pop_back().queue_free()
		draw_waypoint(from, Color.RED)
		from = before_last_cast.global_position
		draw_waypoint(from, Color.BLUE)
	else:
		unwrap_point = before_last_cast.get_collision_point()
		#before_last_cast.target_position = last_target_pos
		
		
		
func draw_waypoint(pos: Vector3, color: Color):
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
