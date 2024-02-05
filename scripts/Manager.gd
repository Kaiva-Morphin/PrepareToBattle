extends Node2D

var mappool = [
	preload("res://maps/map_1.tscn"),
	preload("res://maps/map_2.tscn"),
	preload("res://maps/map_3.tscn"),
	preload("res://maps/map_4.tscn"),
	preload("res://maps/map_5.tscn"),
	preload("res://maps/map_6.tscn"),
	preload("res://maps/map_7.tscn"),
	preload("res://maps/map_8.tscn"),
]
var map_textures = [
	load("res://maps/Castle.png"),
	load("res://maps/White.png"),
	load("res://maps/Forest.png"),
	load("res://maps/Void.png"),
	load("res://maps/Beach.png"),
	load("res://maps/Mansion.png"),
	load("res://maps/Plot.png")
]

@onready var camera = $Camera
@onready var ui = $UILayer/UI

func next_level():
	Game.current_state = Game.GameState.prepare
	for node in get_tree().get_nodes_in_group("projectile"): node.despawn()
	var prev_map = get_node_or_null("map")
	if prev_map:
		remove_child(prev_map)
		prev_map.queue_free()
	var map = mappool.pick_random().instantiate()
	var tilemap : TileMap = map.get_node_or_null("TileMap")
	if tilemap:
		tilemap.tile_set.get_source(0).texture = map_textures.pick_random()

	map.name = "map"
	self.add_child(map)
	camera.update_bounds()
	ui.update_spawn_rects()
	ui.prepare()
	$CheckAlive.start()
	# spawn enemies
	var number_of_enemies : int = round(Game.difficulty * Game.difficulty_enemy_multipler)
	var spawn_rects = get_node("map/EnemySpawners").get_children()
	for i in range(number_of_enemies):
		var rect : Rect2 = spawn_rects.pick_random().get_global_rect()
		var spawn_pos = rect.position + Vector2(randf() * rect.size.x, randf() * rect.size.y)
		var enemy : Entity = get_random_binded_man()
		enemy.team = Game.Team.enemy
		add_child(enemy)
		enemy.global_position = spawn_pos


func _on_check_alive_timer_timeout() -> void:
	if Game.current_state == Game.GameState.inbattle:
		var enemy = []
		var player = []
		for e : Entity in get_tree().get_nodes_in_group("entity"):
			if !e.in_inventory:
				match e.team:
					Game.Team.player:
						player.append(e)
					Game.Team.enemy:
						enemy.append(e)
		if len(player) == 0:
			print("GAME OVER!")
		if len(enemy) == 0:
			for p in player:
				p.reset()
				ui.add_to_bar(p)
			Game.difficulty *= 2
			next_level()
	else:
		$CheckAlive.stop()


func get_closest_oppositive_team_member(pos : Vector2, team : Game.Team) -> Node2D:
	var tree = get_tree()
	match team:
		Game.Team.enemy:
			var closest : Node2D = null
			var closest_val : float
			for node in tree.get_nodes_in_group("player"):
				if !node.in_inventory:
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
				if !node.in_inventory:
					var dist : float = pos.distance_squared_to(node.global_position) ** 2
					if closest == null or dist < closest_val:
						closest = node
						closest_val = dist
			if closest:
				return closest
		Game.Team.other:
			pass
	return null

func _on_attack_button_pressed() -> void:
	for entity in get_tree().get_nodes_in_group("entity"):
		if !entity.in_inventory:
			entity.unpause()
			Game.current_state = Game.GameState.inbattle
			ui.in_battle()
			$CheckAlive.start()

var weapons = [
	[preload("res://weapons/Axes.tscn"), Stats.WeaponArchiType.Axe],
	[preload("res://weapons/Fists.tscn"), Stats.WeaponArchiType.Fists],
	[preload("res://weapons/Knifes.tscn"), Stats.WeaponArchiType.Knife],
	[preload("res://weapons/Rapiers.tscn"), Stats.WeaponArchiType.Rapier],
	[preload("res://weapons/Swords.tscn"), Stats.WeaponArchiType.Sword],
	[preload("res://weapons/WarStaffs.tscn"), Stats.WeaponArchiType.WarStaff],
]

func get_random_binded_man() -> Entity:
	var man = preload("res://entities/Man.tscn").instantiate()
	var w = weapons.pick_random()
	var weapon = w[0].instantiate().duplicate()
	weapon.randomize_texture()
	weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(w[1])
	man.character_attributes = Stats.get_random_character_attributes()
	man.set_weapon_noupdate(weapon)
	man.generate_container()
	return man
