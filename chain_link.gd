extends Node3D
class_name ChainLink

@export var line_color: Color = Color.CYAN
var chain_links: Array[MeshInstance3D]

func get_links():
	return chain_links.size()
	

func add_link():	
	var link = MeshInstance3D.new()
	link.top_level = true
	chain_links.append(link)
	add_child(link)
	link.mesh = ImmediateMesh.new()
	
func update_link(link_index: int, start: Vector3, end: Vector3):
	var link = chain_links[link_index]
	var material = ORMMaterial3D.new()
	link.mesh = ImmediateMesh.new()
	link.mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES, material)
	link.mesh.surface_add_vertex(start)
	link.mesh.surface_add_vertex(end)
	link.mesh.surface_end()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color
	
	#draw_contact_point(start, Color.RED)
	#draw_contact_point(end, Color.GREEN)
	
func update_end_link(start: Vector3, end: Vector3):
	update_link(get_links()-1, start, end)
	
func set_color(new_color: Color):
	for link in chain_links:
		link.get_active_material(0).albedo_color = new_color
		print(link.get_active_material(0))
		
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
	
	
