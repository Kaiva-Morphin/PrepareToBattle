extends Node2D




func get_closest_oppositive_team_member(pos : Vector2, team : Game.Team) -> Node2D:
	var tree = get_tree()
	match team:
		Game.Team.enemy:
			var closest : Node2D = null
			var closest_val : float
			for node in tree.get_nodes_in_group("player"):
				var dist : float = pos.distance_squared_to(node.global_position) ** 2
				if closest == null or dist < closest_val:
					closest = node
					closest_val = dist
			if closest:
				return closest
		Game.Team.player:
			var closest : Node2D = null
			var closest_val : float
			for node in tree.get_nodes_in_group("enemy"):
				var dist : float = pos.distance_squared_to(node.global_position) ** 2
				if closest == null or dist < closest_val:
					closest = node
					closest_val = dist
			if closest:
				return closest
		Game.Team.other:
			pass
	return null


#
#var picked_node : Node2D = null
#func _process(_delta: float) -> void:
	#var pos = get_global_mouse_position()
	#if Input.is_action_just_pressed("lmb"):
		#if picked_node:
			#picked_node = null
		#else:
			#picked_node = null
			#if space_state:
				#var query = PhysicsRayQueryParameters2D.create(pos - Vector2(20, 20), pos + Vector2(20, 20))
				#var result = space_state.intersect_ray(query)
				#if result:
					#var col = result.collider
					#if col.is_in_group("entity"):
						#picked_node = col
	#if picked_node:
		#picked_node.position = pos
	##var pos = 
	##var c = $PICKER/Ray.get_collider()
	#
#
