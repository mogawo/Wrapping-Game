@tool
extends Node3D
class_name Chain

@export var link = preload("res://link.tscn")
@export var seperation = 2
@export_range(0, 10) var length = 0

var link_array: Array[Node]
var joint_array: Array[PinJoint3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#clear_links()
	#print_linkage()
	handle_linkage()

func print_linkage():
	print("Links: ", link_array)
	print("Joints: ", joint_array)

func handle_linkage():	
	var diff = length - link_array.size()
	if diff == 0: return
	var link_call: Callable = add_link if diff > 0 else remove_link
	link_call.call()

func clear_links():
	for l in link_array:
		l.queue_free()
	link_array.clear()
	for j in joint_array:
		j.queue_free()
	joint_array.clear()
	
func remove_link():
	#print("remove_link")
	if not link_array.is_empty(): link_array.pop_back().queue_free()
	if not joint_array.is_empty(): joint_array.pop_back().queue_free()
	
func add_link():
	#print("add_link")
	var new_link = link.instantiate()
	var dir = link_array.front().transform.basis.y if not link_array.is_empty() else Vector3.UP
	new_link.position = dir * link_array.size() * seperation
	add_child(new_link)
	link_array.append(new_link)
	attach_joint()
	
	
func attach_joint():
	var new_link = link_array.back()
	if link_array.size() > 1:
		var new_joint := PinJoint3D.new()
		new_joint.set_param(PinJoint3D.Param.PARAM_BIAS, 0.3)
		new_joint.set_param(PinJoint3D.Param.PARAM_DAMPING, 1)
		new_joint.set_param(PinJoint3D.Param.PARAM_IMPULSE_CLAMP, 0)
		var sep = 2 * (link_array.size()-2) + 1
		new_joint.position = link_array.front().transform.basis.y * sep
		new_joint.node_a = new_link.get_path()
		new_joint.node_b = link_array[link_array.size() - 2].get_path()
		add_child(new_joint)
		joint_array.append(new_joint)
