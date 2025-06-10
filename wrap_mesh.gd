extends Node3D
class_name WrapMesh

@export var line_color: Color = Color.CYAN
var wrap_meshes: Array[MeshInstance3D]
var from: Vector3

func get_wraps():
	return wrap_meshes.size()
	

func add_wrap_mesh():	
	var wrap = MeshInstance3D.new()
	wrap.top_level = true
	wrap_meshes.append(wrap)
	add_child(wrap)
	wrap.mesh = ImmediateMesh.new()
	
	
func update_last_wrap(from_here: Vector3, to: Vector3):
	var flag = false
	if wrap_meshes.size() == 1:
		from = global_position
	if from != from_here:
		to = from_here
		flag = true
		
		
	
	var wrap = wrap_meshes.back()
	var material = ORMMaterial3D.new()
	wrap.mesh = ImmediateMesh.new()
	wrap.mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES, material)
	wrap.mesh.surface_add_vertex(from)
	wrap.mesh.surface_add_vertex(to)
	wrap.mesh.surface_end()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color
	
	if flag:
		from = from_here
		add_wrap_mesh()

func set_color(new_color: Color):
	for wrap in wrap_meshes:
		wrap.get_active_material(0).albedo_color = new_color
		print(wrap.get_active_material(0))
		
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
	
	
