extends Node3D
class_name ChainLink

@export var line_color: Color = Color.CYAN
var chain_link: Array[MeshInstance3D]

func get_links():
	return chain_link.size()
	

func add_link():	
	var rope = MeshInstance3D.new()
	self.add_child(rope)
	rope.mesh = ImmediateMesh.new()
		
func update_link(link_index: int, start: Vector3, end: Vector3):
	var link = chain_link[link_index]
	var material = ORMMaterial3D.new()
	link.mesh = ImmediateMesh.new()
	link.mesh.surface_begin(Mesh.PrimitiveType.PRIMITIVE_LINES, material)
	link.mesh.surface_add_vertex(start)
	link.mesh.surface_add_vertex(end)
	link.mesh.surface_end()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = line_color
	
func update_end_link(start: Vector3, end: Vector3):
	update_link(get_links()-1, start, end)
	
func set_color(new_color: Color):
	for link in chain_link:
		link.get_active_material(0).albedo_color = new_color
		print(link.get_active_material(0))
	
	
