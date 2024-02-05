extends Control


var inventory_opened = false
var cell_texture = load("res://src/sprites/UI/InventoryCell.png")
var character = preload("res://Entities/Man.tscn")


@onready var inventory_bg = $Prepare/Inventory
@onready var squad_selector = $Prepare/Selector
@onready var squad_selector_frame_container = $Prepare/Selector/ScrollContainer/HBoxContainer

var space_state : PhysicsDirectSpaceState2D = null
func _physics_process(_delta: float) -> void:
	space_state = get_world_2d().direct_space_state

func update_spawn_rects():
	var spawn_rects_node = get_tree().root.get_node_or_null("Manager/map/PlayerSpawners")
	spawn_rects = []
	if spawn_rects_node:
		for c in spawn_rects_node.get_children():
			spawn_rects.append(c)

var spawn_rects = []
var picked_node = null
func _process(_delta: float) -> void:
	var pos = Game.manager.get_global_mouse_position()
	if Game.current_state == Game.GameState.prepare: # characters
		if Input.is_action_just_pressed("lmb"):
			if !is_inventory_open:
				if picked_node:
					picked_node = null
				else:
					picked_node = null
					if space_state:
						var query = PhysicsRayQueryParameters2D.create(pos - Vector2(20, 20), pos + Vector2(20, 20))
						var result = space_state.intersect_ray(query)
						if result:
							var col = result.collider
							if col.is_in_group("entity") and col.is_in_group("player"):
								$Prepare/Selector/Hint.show()
								$PickPlayer.play()
								picked_node = col
								picked_node.collision.disabled = true
								picked_node.in_inventory = true
		if Input.is_action_just_released("lmb"):
			if picked_node:
				var rect = squad_selector.get_global_rect()
				if rect.has_point(get_global_mouse_position()):
					$BackToInventory.play()
					picked_node.collision.disabled = true
					picked_node.in_inventory = true
					add_to_bar(picked_node)
				else:
					var is_any_spawn_rect_has_mouse = false
					for spawn_rect in spawn_rects:
						if spawn_rect.get_global_rect().has_point(pos):
							is_any_spawn_rect_has_mouse = true
							break
					if is_any_spawn_rect_has_mouse:
						$PutPlayer.play()
						picked_node.in_inventory = false
						picked_node.collision.disabled = false
					else:
						$WrongPlace.play()
						picked_node.collision.disabled = true
						picked_node.in_inventory = true
						add_to_bar(picked_node)
				$Prepare/Selector/Hint.hide()
				picked_node = null
		if picked_node:
			picked_node.position = pos
		if picked_item:
			picked_item.position = inventory_bg.get_local_mouse_position()
	else: #potions
		if Input.is_action_pressed("lmb"):
			if picked_node:
				picked_node.position = pos
		if Input.is_action_just_released("lmb"):
			if picked_node:
				var rect = $InBattle/Selector.get_global_rect()
				if rect.has_point(get_global_mouse_position()):
					$BackToInventory.play()
					potion_to_bar(picked_node)
					picked_node = null
				else:
					picked_node.apply_effect()
					picked_node.queue_free()
					picked_node = null
					$"../../PotionDrop".play(0.45)
					pass # apply potion


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			if !picked_node and !is_inventory_open:
				var rect = squad_selector.get_global_rect()
				if !rect.has_point(get_global_mouse_position()):
					Game.manager.camera.target_position += -event.relative / Game.manager.camera.zoom.x
				


func add_to_bar(e: Entity):
	var rect = TextureRect.new()
	rect.texture = cell_texture
	rect.custom_minimum_size = Vector2(64, 64)
	rect.connect("gui_input", func(event): _bar_cell_gui_input(event, e) )
	squad_selector_frame_container.add_child(rect)
	e.reset()
	e.in_inventory = true
	if e.get_parent():
		e.reparent(rect)
	else:
		rect.add_child(e)
	e.scale = Vector2.ONE * 2
	e.position = rect.custom_minimum_size / 2


func _bar_cell_gui_input(event: InputEvent, e : Entity) -> void: # for picking, not drop
	if picked_node: return
	if Game.current_state != Game.GameState.prepare: return
	if is_inventory_open: # select
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == 1:
				$PickPlayer.play()
				inventory_selected_character = e
				update_inventory_character_preview()
				call_deferred("update_slot_tooltip", head_slot)
				call_deferred("update_slot_tooltip", chest_slot)
				call_deferred("update_slot_tooltip", legs_slot)
				call_deferred("update_slot_tooltip", accessory1_slot)
				call_deferred("update_slot_tooltip", accessory2_slot)
				call_deferred("update_slot_tooltip", weapon_slot)
	else: # check for put
		if event is InputEventScreenDrag:
			if !picked_node:
				var rect = squad_selector.get_global_rect()
				#rect.position -= Vector2(2, 2)
				#rect.size += Vector2(2, 2) 
				if rect.has_point(get_global_mouse_position()):
					pass
				else: # put
					$PickPlayer.play()
					$Prepare/Selector/Hint.show()
					picked_node = e
					picked_node.scale = Vector2.ONE
					var frame = e.get_parent()
					picked_node.reparent(Game.manager)
					frame.queue_free()


var inventory_selected_character : Entity = null

var is_inventory_open = false


func _on_inventory_button_pressed() -> void:
	is_inventory_open = !is_inventory_open
	if is_inventory_open:
		open_inventory()
	else:
		close_inventory()

func open_inventory():
	is_inventory_open = true
	$OpenInventory.play()
	$Prepare/InventoryButton.texture_normal.region.position = Vector2(32, 0)
	$Prepare/InventoryButton.texture_pressed.region.position = Vector2(48, 0)
	inventory_selected_character = null
	update_slot_tooltip(head_slot)
	update_slot_tooltip(chest_slot)
	update_slot_tooltip(legs_slot)
	update_slot_tooltip(accessory1_slot)
	update_slot_tooltip(accessory2_slot)
	update_slot_tooltip(weapon_slot)
	update_inventory_character_preview()
	$Prepare/Inventory.show()


func close_inventory():
	is_inventory_open = false
	$CloseInventory.play()
	if picked_item:
		picked_item.reparent(picked_item_slot)
		picked_item.position = slot_offset
		picked_item = null
		picked_item_slot = null
	$Prepare/InventoryButton.texture_normal.region.position = Vector2(0, 0)
	$Prepare/InventoryButton.texture_pressed.region.position = Vector2(16, 0)
	$Prepare/Inventory.hide()

func in_battle():
	if picked_node:
		if picked_node is Entity:
			picked_node.collision.disabled = true
			picked_node.in_inventory = true
			add_to_bar(picked_node)
	close_inventory()
	$Prepare.hide()
	$InBattle.show()

func prepare():
	$Prepare.show()
	$InBattle.hide()

@onready var inventory_container = $Prepare/Inventory/ScrollContainer/GridContainer

var slot_offset = Vector2(24, 24)



var picked_item : Item = null
var picked_item_slot : Slot = null

func item_selected(event: InputEvent, slot: Slot):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if picked_item_slot:
				return try_swap_slots(picked_item_slot, slot)
			else:
				var item = slot.get_item_or_null()
				if item:
					$InventorySound.play()
					picked_item_slot = slot
					picked_item = item
					picked_item.reparent(inventory_bg)
					return true
				#else:
					#try_put(picked_item_slot, slot)
	

func try_swap_slots(_picked_item_slot : Slot, slot : Slot) -> bool:
	if _picked_item_slot == slot: # drop
		if picked_item_slot.wearable_slot:
			$InventoryWear.play()
		else:
			$InventoryPut.play()
		#else:
		#	
		picked_item.reparent(slot)
		update_slot_tooltip(slot)
		picked_item.position = slot_offset
		picked_item_slot = null
		picked_item = null
		return true
	var item = slot.get_item_or_null()
	if !inventory_selected_character and (_picked_item_slot.wearable_slot or slot.wearable_slot):
		$InventoryWrong.play()
		return false
	if slot.specific_type == picked_item.item_type or slot.specific_type == Game.ItemType.any:
		if item: # swap
			if _picked_item_slot.wearable_slot || slot.wearable_slot :
				$InventoryWear.play()
			else:
				$InventorySound.play()
			if (_picked_item_slot.specific_type == item.item_type or _picked_item_slot.specific_type == Game.ItemType.any): #_picked_item_slot != weapon_slot:#
				picked_item.reparent(slot)
				update_slot_tooltip(slot)
				picked_item.position = slot_offset
				item.reparent(inventory_bg)
				update_slot_tooltip(picked_item_slot)
				picked_item = item
				return true
			else:
				# swap
				
				#if _picked_item_slot.specific_type == item.item_type:
				var new_slot = $Prepare/Inventory/ScrollContainer/Slot_Template.duplicate()
				new_slot.show()
				$Prepare/Inventory/ScrollContainer/GridContainer.add_child(new_slot)
				new_slot.connect("gui_input", func(event): item_selected(event, new_slot))
				picked_item.reparent(slot)
				update_slot_tooltip(slot)
				picked_item.position = slot_offset
				item.reparent(inventory_bg)
				picked_item_slot = new_slot
				update_slot_tooltip(picked_item_slot)
				picked_item = item
				return true
		else: # wear
			$InventoryWear.play()
			picked_item.reparent(slot)
			update_slot_tooltip(slot)
			picked_item.position = slot_offset
			picked_item = null
			if !picked_item_slot.wearable_slot:
				picked_item_slot.queue_free()
			picked_item_slot = null
			return true
	$InventoryWrong.play()
	return false


func add_item(item: Item):
	var slot = $Prepare/Inventory/ScrollContainer/Slot_Template.duplicate()
	slot.show()
	item.scale = Vector2.ONE * 2
	if item.get_parent():
		item.reparent(slot)
	else:
		slot.add_child(item)
	item.position = slot_offset
	$Prepare/Inventory/ScrollContainer/GridContainer.add_child(slot)
	update_slot_tooltip(slot)
	slot.connect("gui_input", func(event): item_selected(event, slot))

func update_slot_tooltip(slot):
	if slot:
		slot.tooltip_text = ""
		slot.self_modulate = Color.WHITE
		var c = slot.get_child_count()
		if c > 0:
			for item in slot.get_children():
				if item is Item:
					slot.self_modulate = Stats.get_rarity_color(item.attributes.item_rarity)
					slot.tooltip_text = item.attributes.as_text()
			
@onready var weapon_slot : Slot = $Prepare/Inventory/WeaponSlot
@onready var head_slot : Slot = $Prepare/Inventory/HeadSlot
@onready var chest_slot : Slot = $Prepare/Inventory/ChestSlot
@onready var legs_slot : Slot = $Prepare/Inventory/LegsSlot
@onready var accessory1_slot : Slot = $Prepare/Inventory/Acc1Slot
@onready var accessory2_slot : Slot = $Prepare/Inventory/Acc2Slot

func _on_head_slot_gui_input(event: InputEvent) -> void:
	if item_selected(event, head_slot):
		var item = head_slot.get_item_or_null() 
		if item:
			var new_item = item.duplicate()
			new_item.attributes = item.attributes
			new_item.scale = Vector2.ONE
			new_item.position = Vector2.ZERO
			inventory_selected_character.set_armor_head(new_item)
		elif inventory_selected_character:
			inventory_selected_character.set_armor_head(null)
		update_inventory_character_preview()
func _on_chest_slot_gui_input(event: InputEvent) -> void:
	if item_selected(event, chest_slot):
		var item = chest_slot.get_item_or_null() 
		if item:
			var new_item = item.duplicate()
			new_item.attributes = item.attributes
			new_item.scale = Vector2.ONE
			new_item.position = Vector2.ZERO
			inventory_selected_character.set_armor_chest(new_item)
		elif inventory_selected_character:
			inventory_selected_character.set_armor_chest(null)
		update_inventory_character_preview()
	
func _on_legs_slot_gui_input(event: InputEvent) -> void:
	if item_selected(event, legs_slot):
		var item = legs_slot.get_item_or_null() 
		if item:
			var new_item = item.duplicate()
			new_item.attributes = item.attributes
			new_item.scale = Vector2.ONE
			new_item.position = Vector2.ZERO
			inventory_selected_character.set_armor_legs(new_item)
		elif inventory_selected_character:
			inventory_selected_character.set_armor_legs(null)
		update_inventory_character_preview()

func _on_acc_1_slot_gui_input(event: InputEvent) -> void:
	if item_selected(event, accessory1_slot):
		var item = accessory1_slot.get_item_or_null() 
		if item:
			var new_item = item.duplicate()
			new_item.attributes = item.attributes
			new_item.scale = Vector2.ONE
			new_item.position = Vector2.ZERO
			inventory_selected_character.set_accessory1(new_item)
		elif inventory_selected_character:
			inventory_selected_character.set_accessory1(null)
		update_inventory_character_preview()

func _on_acc_2_slot_gui_input(event: InputEvent) -> void:
	if item_selected(event, accessory2_slot):
		var item = accessory2_slot.get_item_or_null() 
		if item:
			var new_item = item.duplicate()
			new_item.attributes = item.attributes
			new_item.scale = Vector2.ONE
			new_item.position = Vector2.ZERO
			inventory_selected_character.set_accessory2(new_item)
		elif inventory_selected_character:
			inventory_selected_character.set_accessory2(null)
		update_inventory_character_preview()
		
		
func _on_weapon_slot_gui_input(event: InputEvent) -> void:
	if !picked_item: return
	if item_selected(event, weapon_slot):
		var item = weapon_slot.get_item_or_null()
		if item:
			#var weapon_node = inventory_selected_character.get_node("Mirror/Weapon")
			#for w in weapon_node.get_children():
				#weapon_node.remove_child(w)
				#w.queue_free()
			var new_weapon = item.duplicate()
			new_weapon.attributes = item.attributes
			new_weapon.scale = Vector2.ONE
			new_weapon.position = Vector2.ZERO
			inventory_selected_character.set_weapon(new_weapon)
			#weapon_node.add_child(new_weapon)
			
			update_inventory_character_preview()
		else:
			print("ZXC!")

@onready var preview_node = $Prepare/Inventory/Preview
func update_inventory_character_preview():
	$Prepare/Inventory/Hint.hide()
	for node in preview_node.get_children():
		preview_node.remove_child(node)
		node.queue_free()
	for child in weapon_slot.get_children():
		weapon_slot.remove_child(child)
		child.queue_free()
	for child in accessory1_slot.get_children():
		accessory1_slot.remove_child(child)
		child.queue_free()
	for child in accessory2_slot.get_children():
		accessory2_slot.remove_child(child)
		child.queue_free()
	for child in legs_slot.get_children():
		legs_slot.remove_child(child)
		child.queue_free()
	for child in chest_slot.get_children():
		chest_slot.remove_child(child)
		child.queue_free()
	for child in head_slot.get_children():
		head_slot.remove_child(child)
		child.queue_free()
	
	if inventory_selected_character:
		var sprite = inventory_selected_character.get_node("Mirror").duplicate()
		var weapon_node = inventory_selected_character.get_node("Mirror/Weapon")
		if weapon_node.get_child_count() > 0:
			var weapon = weapon_node.get_child(0).duplicate()
			weapon.attributes = weapon_node.get_child(0).attributes
			weapon_slot.add_child(weapon)
			weapon.scale = Vector2.ONE * 2
			weapon.position = slot_offset
		
		var item_node = inventory_selected_character.get_node("Mirror/Sprite/Head/HeadArmor")
		if item_node.get_child_count() > 0:
			var item = item_node.get_child(0).duplicate()
			item.attributes = item_node.get_child(0).attributes
			head_slot.add_child(item)
			item.scale = Vector2.ONE * 2
			item.position = slot_offset
		
		item_node = inventory_selected_character.get_node("Mirror/Sprite/Head/Accessory1")
		if item_node.get_child_count() > 0:
			var item = item_node.get_child(0).duplicate()
			item.attributes = item_node.get_child(0).attributes
			accessory1_slot.add_child(item)
			item.scale = Vector2.ONE * 2
			item.position = slot_offset
		
		item_node = inventory_selected_character.get_node("Mirror/Sprite/Head/Accessory2")
		if item_node.get_child_count() > 0:
			var item = item_node.get_child(0).duplicate()
			item.attributes = item_node.get_child(0).attributes
			accessory2_slot.add_child(item)
			item.scale = Vector2.ONE * 2
			item.position = slot_offset
		
		item_node = inventory_selected_character.get_node("Mirror/Sprite/Body")
		if item_node.get_child_count() > 0:
			var item = item_node.get_child(0).duplicate()
			item.attributes = item_node.get_child(0).attributes
			chest_slot.add_child(item)
			item.scale = Vector2.ONE * 2
			item.position = slot_offset
		
		item_node = inventory_selected_character.get_node("Mirror/Sprite/HiddenLegs")
		if item_node.get_child_count() > 0:
			var item = item_node.get_child(0).duplicate()
			item.attributes = item_node.get_child(0).attributes
			legs_slot.add_child(item)
			item.scale = Vector2.ONE * 2
			item.position = slot_offset
		preview_node.add_child(sprite)
		sprite.scale = Vector2.ONE * 5
	else:
		if squad_selector_frame_container.get_child_count() > 0:
			inventory_selected_character = squad_selector_frame_container.get_child(0).get_child(0)
			update_inventory_character_preview()
		else:
			$Prepare/Inventory/Hint.show()
	if inventory_selected_character:
		inventory_selected_character.attribute_container.force_update()
		$Prepare/Inventory/Stats/RichTextLabel.text = inventory_selected_character.attribute_container.get_as_rich_text()
	update_slot_tooltip(head_slot)
	update_slot_tooltip(chest_slot)
	update_slot_tooltip(legs_slot)
	update_slot_tooltip(accessory1_slot)
	update_slot_tooltip(accessory2_slot)
	update_slot_tooltip(weapon_slot)
	

func _on_inventory_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if picked_item:
				add_item(picked_item)
				picked_item = null
				if !picked_item_slot.wearable_slot:
					picked_item_slot.queue_free()
				picked_item_slot = null



func _ready():
	is_inventory_open = $Prepare/Inventory.visible
	#pick_potion
	$InBattle/Selector/ScrollContainer/HBoxContainer/Tornado.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/Tornado) )
	$InBattle/Selector/ScrollContainer/HBoxContainer/RagePotion.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/RagePotion) )
	$InBattle/Selector/ScrollContainer/HBoxContainer/PositionPotion.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/PositionPotion) )
	$InBattle/Selector/ScrollContainer/HBoxContainer/LightingPotion.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/LightingPotion) )
	$InBattle/Selector/ScrollContainer/HBoxContainer/HealPotion.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/HealPotion) )
	$InBattle/Selector/ScrollContainer/HBoxContainer/ChaosPotion.connect("gui_input", func(event): potion_gui_input(event, $InBattle/Selector/ScrollContainer/HBoxContainer/ChaosPotion) )
	#


func add_potion():
	pass
	#$InBattle/Selector/ScrollContainer/HBoxContainer.add_child()

func potion_to_bar(potion : Potion):
	if potion:
		potion.custom_minimum_size = Vector2.ONE * 64
		potion.size = Vector2.ONE * 64
		if potion.get_parent():
			potion.reparent($InBattle/Selector/ScrollContainer/HBoxContainer)
		else:
			$InBattle/Selector/ScrollContainer/HBoxContainer.add_child(potion)
		potion.connect("gui_input", func(event): potion_gui_input(event,  potion))



var picked_potion_node : Potion = null
func potion_gui_input(event, potion : Potion ):
	if picked_node: return
	#if Game.current_state == Game.GameState.prepare: return
	if event is InputEventScreenDrag:
		if !picked_potion_node:
			var rect = $InBattle/Selector.get_global_rect()
			if rect.has_point(get_global_mouse_position()): # put
				pass
			else: # pick
				$PickPlayer.play()
				#$Prepare/Selector/Hint.show()
				var new_potion = potion.duplicate()
				potion.queue_free() # for clearing signal
				picked_node = new_potion
				new_potion.custom_minimum_size = Vector2.ONE * 16
				new_potion.size = Vector2.ONE * 16
				Game.manager.add_child(new_potion)




func _on_settings_button_pressed() -> void:
	var tween = create_tween()
	if $Settings.visible:
		tween.tween_property($SettingsButton, "rotation", PI * 2, 0.3)
		$Settings.hide()
	else:
		tween.tween_property($SettingsButton, "rotation", 0, 0.3)
		$Settings.show()

var master_bus_idx = AudioServer.get_bus_index("Master")
var inventory_bus_idx = AudioServer.get_bus_index("Inventory")
var bg_music_bus_idx = AudioServer.get_bus_index("Background")
var bt_music_bus_idx = AudioServer.get_bus_index("Battle")
var entity_bus_idx = AudioServer.get_bus_index("Entity")

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_idx, value < 0.05)


func _on_inventory_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(inventory_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(inventory_bus_idx, value < 0.05)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bg_music_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bg_music_bus_idx, value < 0.05)
	AudioServer.set_bus_volume_db(bt_music_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bt_music_bus_idx, value < 0.05)


func _on_entity_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(entity_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(entity_bus_idx, value < 0.05)



