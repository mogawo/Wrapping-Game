@tool
extends Node3D
class_name Chain

@export var link = load("res://link.tscn")
@export var seperation = 2
@export_range(1, 10) var length = 1

var link_array: Array[Node]
var joint_array: Array[PinJoint3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var current = get_child(0)
	#for i in range(length):	
		#var new_link: Link = link.instantiate()
		#add_child(new_link)
		#attach(current, new_link)
		##print(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var diff = link_array.size() - length
	
	#link_array.clear()
	if diff < 0:
		var new_link = link.instantiate()
		var dir = link_array.front().transform.basis.y if not link_array.is_empty() else Vector3.UP
		new_link.position = dir * link_array.size() * seperation
		add_child(new_link)
		link_array.append(new_link)
		if link_array.size() > 1:
			var new_joint := PinJoint3D.new()
			print(typeof(new_joint.PARAM_BIAS))
			new_joint.set_param(PinJoint3D.Param.PARAM_BIAS, 0.3)
			new_joint.set_param(PinJoint3D.Param.PARAM_DAMPING, 1)
			new_joint.set_param(PinJoint3D.Param.PARAM_IMPULSE_CLAMP, 0)
			print(link_array.front().transform.basis.y)
			var sep = 2 * (link_array.size()-2) + 1
			new_joint.position = link_array.front().transform.basis.y * sep
			new_joint.node_a = new_link.get_path()
			new_joint.node_b = link_array[link_array.size() - 2].get_path()
			add_child(new_joint)
			
			joint_array.append(new_joint)
		pass
	elif diff > 0:
		link_array.pop_back().queue_free()
		joint_array.pop_back().queue_free()
	else:
		#draw_contact_point(joint_array.back().global_position, Color.RED)
		#get_children().pop_back().queue_free()
		#link_array.pop_back().queue_free()
		#link_array.clear()
		#joint_array.pop_back().queue_free()
		#get_children().pop_back().queue_free()
		#for c in get_children():
			#remove_child(c)
			#c.queue_free()
		#get_children().clear()
		
		pass
	#print("Children: ", get_children())
	#print("LinkArray: ", link_array)
	#print(diff)

func _physics_process(delta: float) -> void:
	attach_links()
	pass
	
func attach_links():
	var link_array = get_children()
	for i in range(1, link_array.size() - 2):
		var before = link_array[i-1]
		var curr = link_array[i]
		var after = link_array[i+1]
		

func handle_linkage(delta: float):
	pass
	
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

	
