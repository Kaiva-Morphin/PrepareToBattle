extends Camera2D

@export var follow_speed : float = 16.
@export var room_bonds_left_up : Vector2
@export var room_bonds_right_bottom : Vector2


enum State{
	Follow,   # follow node
	RoomSlide # follow node, but in room bounds
}



var current_state = State.Follow

@export var target_zoom = 2.

var max_zoom = 5.
var min_zoom = 0.5

var target_position = Vector2.ZERO

func update_bounds():
	#room_bonds_left_up = null
	#room_bonds_right_bottom = null
	var room_bonds_left_up_node = Game.manager.get_node_or_null("map/Bounds/LeftUp")
	var room_bonds_right_bottom_node = Game.manager.get_node_or_null("map/Bounds/RightBottom")
	if room_bonds_left_up_node and room_bonds_right_bottom_node:
		room_bonds_left_up = room_bonds_left_up_node.global_position
		room_bonds_right_bottom = room_bonds_right_bottom_node.global_position
		var rect = (room_bonds_right_bottom - room_bonds_left_up)
		var screen_size = get_viewport_rect().size
		var min_val = min(screen_size.x / rect.x, screen_size.y/ rect.y) * 2
		#1.04
		print(min_val)
		min_zoom = min_val
		

func _process(delta):
	if !$"../UILayer/UI".is_inventory_open:
		if Input.is_action_just_pressed("mwup"): target_zoom += 0.1 * sqrt(self.zoom.x)
		if Input.is_action_just_pressed("mwdn"): target_zoom -= 0.1 * sqrt(self.zoom.x)
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	#print(target_zoom)
	self.zoom = lerp(self.zoom, Vector2(target_zoom, target_zoom), delta * follow_speed)
	#self.position = target_position
	
	var world_screen_size = get_viewport_rect().size / zoom * 0.5
	if !room_bonds_left_up and ! room_bonds_right_bottom:
		self.global_position = lerp(self.global_position, target_position, delta * follow_speed)
		target_position = self.global_position
	else:
		var size = (room_bonds_right_bottom - room_bonds_left_up).abs()
		var center =  ( room_bonds_right_bottom + room_bonds_left_up ) / 2.
		if target_position.x + world_screen_size.x > room_bonds_right_bottom.x:
			target_position.x = room_bonds_right_bottom.x - world_screen_size.x
		if target_position.x - world_screen_size.x < room_bonds_left_up.x:
			target_position.x = room_bonds_left_up.x + world_screen_size.x
		if target_position.y - world_screen_size.y < room_bonds_left_up.y:
			target_position.y = room_bonds_left_up.y + world_screen_size.y
		if target_position.y + world_screen_size.y > room_bonds_right_bottom.y:
			target_position.y = room_bonds_right_bottom.y - world_screen_size.y
		if world_screen_size.x * 2. > size.x:
			target_position.x = center.x
		if (world_screen_size.y) * 2. > size.y:
			target_position.y = center.y
		self.global_position = lerp(self.global_position, target_position, delta * follow_speed)
