extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	func1()

func func2():
	var tree = get_tree()
	var point = get_global_mouse_position()
	var closest : Node2D = null
	var closest_val = 0.0
	for node in tree.get_nodes_in_group("enemy"):
		var dist : float = point.distance_squared_to(node.global_position)
		if closest == null or dist < closest_val ** 2:
			closest = node
			closest_val = dist
	if closest:
		$"../SHOWER".position = closest.position


func func1():
	var closest_node = null
	var closest_node_distance = 0.0
	var tree = get_tree()
	var array = tree.get_nodes_in_group("enemy")
	var point = get_global_mouse_position()
	for i in array:
		var current_node_distance = point.distance_squared_to(i.global_position) ** 2
		if closest_node == null or current_node_distance < closest_node_distance:
			closest_node = i
			closest_node_distance = current_node_distance
	if closest_node:
		$"../SHOWER".position = closest_node.position
