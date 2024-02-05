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
	Game.stages_passed += 1
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
	
	$CheckAlive.start()
	# spawn enemies
	Game.difficulty = Game.stages_passed ** 1.5
	var number_of_enemies : int = round(Game.difficulty * Game.difficulty_enemy_multipler)
	var spawn_rects = get_node("map/EnemySpawners").get_children()
	for i in range(number_of_enemies):
		var rect : Rect2 = spawn_rects.pick_random().get_global_rect()
		var spawn_pos = rect.position + Vector2(randf() * rect.size.x, randf() * rect.size.y)
		var enemy : Entity = get_random_binded_man()
		enemy.team = Game.Team.enemy
		add_child(enemy)
		enemy.global_position = spawn_pos
	ui.prepare()
	chest()

func _ready() -> void:
	#chest()
	pass

var chest_closed = false
func chest():
	chest_closed = true
	$UILayer/UI/Prepare/Selector.hide()
	$UILayer/UI/Chest/ChestBackground/ChestAnim.play("RESET")
	$UILayer/UI/Chest/ChestBackground/SpinnerAnim.play("spinner")
	$UILayer/UI/Chest.show()


var chest_items = 0
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE) || Input.is_action_just_pressed("lmb"):
		if chest_closed:
			chest_closed = false
			$UILayer/UI/Chest/ChestBackground/ChestAnim.play("open")
			
			var accessory_count = Stats.ValueDistribution.new(1., 5.).get_random_value()
			var weapon_count = Stats.ValueDistribution.new(1., 5.).get_random_value()
			var armor_count = Stats.ValueDistribution.new(1., 5.).get_random_value()
			var character_chance = 100.
			var potion_chance = 100.
			var card_chance = 30.
			var has_potion = Stats.ValueDistribution.new(0., 100.).get_random_value() < card_chance
			var has_character = Stats.ValueDistribution.new(0., 100.).get_random_value() < character_chance
			var has_card = Stats.ValueDistribution.new(0., 100.).get_random_value() < character_chance
			# armor -> weapon -> potion -> character -> card
			await get_tree().create_timer(2.5).timeout
			$UILayer/UI/Chest/ChestBackground/Card.show()
			
			
			for a in range(accessory_count):
				for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					n.queue_free()
				$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				var item = get_random_accessory()
				var preview = item.duplicate()
				preview.scale = Vector2.ONE * 5
				ui.add_item(item)
				$UILayer/UI/Chest/ChestBackground/Card/Message.text = item.attributes.as_rich_text()
				$UILayer/UI/Chest/ChestBackground/Card/Preview.add_child(preview)
				await $UILayer/UI/Chest/ChestBackground/Card.pressed
			
			for a in range(armor_count):
				for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					n.queue_free()
				$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				var item = get_random_armor()
				var preview = item.duplicate()
				preview.scale = Vector2.ONE * 5
				ui.add_item(item)
				$UILayer/UI/Chest/ChestBackground/Card/Message.text = item.attributes.as_rich_text()
				$UILayer/UI/Chest/ChestBackground/Card/Preview.add_child(preview)
				await $UILayer/UI/Chest/ChestBackground/Card.pressed
			
			for w in range(weapon_count):
				for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					n.queue_free()
				$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				var item = get_random_weapon()
				var preview = item.duplicate()
				preview.scale = Vector2.ONE * 5
				ui.add_item(item)
				$UILayer/UI/Chest/ChestBackground/Card/Message.text = item.attributes.as_rich_text()
				$UILayer/UI/Chest/ChestBackground/Card/Preview.add_child(preview)
				await $UILayer/UI/Chest/ChestBackground/Card.pressed
			
			if has_potion:
				for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					n.queue_free()
				var item = get_random_potion()
				var preview = item.duplicate()
				ui.potion_to_bar(item)
				$UILayer/UI/Chest/ChestBackground/Card/Message.text = item.as_rich_text()
				$UILayer/UI/Chest/ChestBackground/Card/Preview.add_child(preview)
				$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				await $UILayer/UI/Chest/ChestBackground/Card.pressed
			
			if has_character:
				for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					n.queue_free()
				$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				var entity = get_random_binded_man()
				var preview = entity.get_node("Mirror/Sprite").duplicate()
				preview.scale = Vector2.ONE * 5
				ui.add_to_bar(entity)
				$UILayer/UI/Chest/ChestBackground/Card/Preview.add_child(preview)
				$UILayer/UI/Chest/ChestBackground/Card/Message.text = entity.attributes.as_rich_text()
				await $UILayer/UI/Chest/ChestBackground/Card.pressed
			
			#if has_card:
				#for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
					#$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
					#n.queue_free()
				#$UILayer/UI/Chest/ChestBackground/CollectedItem.play()
				#await $UILayer/UI/Chest/ChestBackground/Card.pressed
			for n in $UILayer/UI/Chest/ChestBackground/Card/Preview.get_children():
				$UILayer/UI/Chest/ChestBackground/Card/Preview.remove_child(n)
				n.queue_free()
			$UILayer/UI/Chest/ChestBackground/Card.hide()
			$UILayer/UI/Prepare/Selector.show()
			$UILayer/UI/Chest.hide()





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
			Game.current_state = Game.GameState.game_over
			$UILayer/UI/GAMEOVER.show()
			$UILayer/UI/GAMEOVER/Label.text = "[center][color=red]Вы продержались {} этапов!".format([Game.stages_passed], "{}")
		if len(enemy) == 0:
			for p in player:
				p.reset()
				ui.call_deferred("add_to_bar", p)
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
	ui.close_inventory()
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
	weapon.attributes = Stats.get_random_weapon_attributes_architype(w[1])
	man.attributes = Stats.get_random_character_attributes()
	man.set_weapon_noupdate(weapon)
	man.generate_container()
	return man

var armors = [
	preload("res://armor/HeadArmor.tscn"),
	preload("res://armor/ChestArmor.tscn"),
	preload("res://armor/LegsArmor.tscn")
]
func get_random_armor() -> Armor:
	var a = armors.pick_random().instantiate()
	a.randomize_texture()
	a.attributes = Stats.get_random_armor_attributes()
	return a

func get_random_accessory() -> Accessory:
	var a = preload("res://accessories/Accessory.tscn").instantiate()
	a.randomize_texture()
	a.attributes = Stats.get_random_item_attributes()
	return a

func get_random_potion() -> Potion:
	var p = Potion.new()
	p.make_random()
	return p

func get_random_weapon() -> Weapon:
	var w = weapons.pick_random()
	var weapon = w[0].instantiate().duplicate()
	weapon.randomize_texture()
	weapon.attributes = Stats.get_random_weapon_attributes_architype(w[1])
	return weapon
