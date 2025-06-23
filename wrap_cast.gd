extends Node3D
class_name WrapCast

var cast_array: Array[RayCast3D]
var from: Vector3

@export_range(0,1) var padding = 0.1
@export_flags_3d_physics var collision_mask
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
	forward_cast.collision_mask = collision_mask
	
	add_child(forward_cast)
	
	if from.length() == 0:
		from = global_position
	
func update_last_cast(to: Vector3):
	var last_cast = cast_array.back() as RayCast3D
	if cast_array.size() == 1:
		from = global_position
		
	last_cast.global_position = from
	last_cast.target_position = to - from
	
	back_cast.global_position = to
	back_cast.target_position = from - to
	#check_unwrap(to)
	check_unwrap_plane(to)
	if last_cast.is_colliding() and back_cast.is_colliding():
		var contact_front = last_cast.get_collision_point()
		var contact_back = back_cast.get_collision_point()
		
		var mid_point = (contact_front + contact_back) / 2
		
		var mid_normal: Vector3
		
		var normal_front = last_cast.get_collision_normal()
		var normal_back = back_cast.get_collision_normal()
		
		mid_normal = (normal_back + normal_front) * padding
		var aprox_from = mid_point + mid_normal
		
		var sphere_cast = ShapeCast3D.new()
		sphere_cast.shape = SphereShape3D.new()
		
		last_cast.add_child(sphere_cast)
		sphere_cast.global_position = aprox_from
		sphere_cast.target_position = Vector3.ZERO
		sphere_cast.collision_mask = collision_mask
		sphere_cast.force_shapecast_update()
		if not sphere_cast.is_colliding():
			print(sphere_cast.shape.radius)
			sphere_cast.shape.radius *= 2
			sphere_cast.force_shapecast_update()
		var sphere_normal = sphere_cast.get_collision_normal(0)
		draw_waypoint(sphere_cast.get_collision_point(0), sphere_cast.get_collision_normal(0), Color.RED)
		from = sphere_cast.get_collision_point(0) + sphere_normal * padding
		
		var wrap_plane = Plane(sphere_normal, from)
		unwrap_planes.append(wrap_plane)
		add_wrap_cast()
	


var unwrap_planes: Array[Plane]
var unwrap_point: Vector3
func check_unwrap_plane(to: Vector3):
	var array_size = cast_array.size() 
	if array_size < 2:
		return
	var before_last_cast = cast_array[array_size - 2]
	var last_plane: Plane = unwrap_planes.back()
	if last_plane.distance_to(back_cast.global_position) >= 0:
		cast_array.pop_back().queue_free()
		before_last_cast.get_child(0).queue_free()
		unwrap_planes.pop_back()
		from = before_last_cast.global_position
	

func check_unwrap(to: Vector3):
	var array_size = cast_array.size() 
	if array_size < 2:
		return
	var before_last_cast = cast_array[array_size - 2]
	before_last_cast.target_position = to - before_last_cast.global_position

	if array_size == 2:
		var reverse_forward_cast_direction = cast_array[array_size-1].global_position.direction_to(cast_array[array_size - 2].global_position).normalized()
		cast_array[array_size - 2].global_position = cast_array[array_size - 1].global_position + reverse_forward_cast_direction
		#draw_waypoint(cast_array[1].global_position, Color.AQUAMARINE)
	
	if not before_last_cast.is_colliding():
		if unwrap_point.distance_to(from) > 1 and array_size == 2:
			pass
		else:
			cast_array.pop_back().queue_free()
			from = before_last_cast.global_position
	else:
		unwrap_point = before_last_cast.get_collision_point()
		
		
		
func draw_waypoint(pos: Vector3, dir: Vector3, color: Color):
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
	waypoint.mesh.surface_add_vertex(pos + dir * 1)
	waypoint.mesh.surface_end()
