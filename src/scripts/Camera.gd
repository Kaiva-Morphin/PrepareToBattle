extends Camera2D

@export var follow_speed : float = 5.
@export var room_bonds_left_up : Vector2
@export var room_bonds_right_bottom : Vector2


enum State{
	Follow,   # follow node
	RoomSlide # follow node, but in room bounds
}



var current_state = State.Follow

@export var target_zoom = 2.
@export var override_zoom : float

var target_position = Vector2.ZERO

func update_bounds():
	pass



func _process(delta):
	if Input.is_action_just_pressed("mwup"): target_zoom += 0.1
	if Input.is_action_just_pressed("mwdn"): target_zoom -= 0.1
	
	self.zoom = lerp(self.zoom, Vector2(target_zoom, target_zoom), delta * follow_speed * 0.5)
	self.position = target_position
	#var world_screen_size = get_viewport_rect().size / zoom * 0.5
	#if follow_node:
		#match current_state:
			#State.Follow:
				#self.global_position = lerp(self.global_position, follow_node.global_position, delta * follow_speed)
			#State.RoomSlide:
				#if !room_bonds_left_up and !! room_bonds_right_bottom:
					#self.global_position = lerp(self.global_position, follow_node.global_position, delta * follow_speed)
				#else:
					#var size = (room_bonds_right_bottom - room_bonds_left_up).abs()
					#var center =  ( room_bonds_right_bottom + room_bonds_left_up ) / 2.
					#var target_position = follow_node.global_position
					#if target_position.x + world_screen_size.x > room_bonds_right_bottom.x:
						#target_position.x = room_bonds_right_bottom.x - world_screen_size.x
					#if target_position.x - world_screen_size.x < room_bonds_left_up.x:
						#target_position.x = room_bonds_left_up.x + world_screen_size.x
					#if target_position.y - world_screen_size.y < room_bonds_left_up.y:
						#target_position.y = room_bonds_left_up.y + world_screen_size.y
					#if target_position.y + world_screen_size.y > room_bonds_right_bottom.y:
						#target_position.y = room_bonds_right_bottom.y - world_screen_size.y
					#if world_screen_size.x * 2. > size.x:
						#target_position.x = center.x
					#if (world_screen_size.y) * 2. > size.y:
						#target_position.y = center.y
					#self.global_position = lerp(self.global_position, target_position, delta * follow_speed)

