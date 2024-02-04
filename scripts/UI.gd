extends Control


var inventory_opened = false
var cell_texture = load("res://src/sprites/UI/InventoryCell.png")
var character = preload("res://src/Entities/Man.tscn")


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
var picked_node : Entity = null
func _process(_delta: float) -> void:
	var pos = Game.manager.get_global_mouse_position()
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
							picked_node = col
							picked_node.collision.disabled = true
							picked_node.in_inventory = true
	if Input.is_action_just_released("lmb"):
		if picked_node:
			var rect = squad_selector.get_global_rect()
			if rect.has_point(get_global_mouse_position()):
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
					picked_node.in_inventory = false
					picked_node.collision.disabled = false
				else:
					picked_node.collision.disabled = true
					picked_node.in_inventory = true
					add_to_bar(picked_node)
			$Prepare/Selector/Hint.hide()
			picked_node = null
	if picked_node:
		picked_node.position = pos
	if picked_item:
		picked_item.position = inventory_bg.get_local_mouse_position()



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
	e.reparent(rect)
	e.scale = Vector2.ONE * 2
	e.position = rect.custom_minimum_size / 2


func _bar_cell_gui_input(event: InputEvent, e : Entity) -> void: # for picking, not drop
	if picked_node: return
	if Game.current_state == Game.GameState.inbattle: return
	if is_inventory_open: # select
		if event is InputEventMouseButton:
			if event.pressed:
				inventory_selected_character = e
				update_inventory_character_preview()
	else: # check for put
		
		if event is InputEventScreenDrag:
			
			if !picked_node:
				var rect = squad_selector.get_global_rect()
				#rect.position -= Vector2(2, 2)
				#rect.size += Vector2(2, 2) 
				if rect.has_point(get_global_mouse_position()):
					pass
				else: # put
					$Prepare/Selector/Hint.show()
					picked_node = e
					picked_node.scale = Vector2.ONE
					var frame = e.get_parent()
					picked_node.reparent(Game.manager)
					frame.queue_free()


var inventory_selected_character : Entity = null

var is_inventory_open = false
func _ready():
	is_inventory_open = $Prepare/Inventory.visible
	#for entity in get_tree().get_nodes_in_group("entity"):
	#	call_deferred("add_to_bar", entity)

func _on_inventory_button_pressed() -> void:
	is_inventory_open = !is_inventory_open
	if is_inventory_open:
		open_inventory()
	else:
		close_inventory()

func open_inventory():
	$Prepare/InventoryButton.texture_normal.region.position = Vector2(32, 0)
	$Prepare/InventoryButton.texture_pressed.region.position = Vector2(48, 0)
	inventory_selected_character = null
	update_inventory_character_preview()
	$Prepare/Inventory.show()

func close_inventory():
	$Prepare/InventoryButton.texture_normal.region.position = Vector2(0, 0)
	$Prepare/InventoryButton.texture_pressed.region.position = Vector2(16, 0)
	$Prepare/Inventory.hide()

func in_battle():
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
					picked_item_slot = slot
					picked_item = item
					picked_item.reparent(inventory_bg)
	
func try_swap_slots(_picked_item_slot : Slot, slot : Slot) -> bool:
	if _picked_item_slot == slot:
		picked_item.reparent(slot)
		update_slot_tooltip(slot)
		picked_item.position = slot_offset
		picked_item_slot = null
		picked_item = null
		return true
	var item = slot.get_item_or_null()
	if !inventory_selected_character and (_picked_item_slot.wearable_slot or slot.wearable_slot): return false
	if slot.specific_type == picked_item.item_type or slot.specific_type == Game.ItemType.any:
		if item: # swap
			if _picked_item_slot.specific_type == item.item_type or _picked_item_slot.specific_type == Game.ItemType.any:
				picked_item.reparent(slot)
				update_slot_tooltip(slot)
				picked_item.position = slot_offset
				item.reparent(inventory_bg)
				update_slot_tooltip(picked_item_slot)
				picked_item = item
				return true
		else:
			picked_item.reparent(slot)
			update_slot_tooltip(slot)
			picked_item.position = slot_offset
			picked_item = null
			if !picked_item_slot.wearable_slot:
				picked_item_slot.queue_free()
			picked_item_slot = null
			return true
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
		var c = slot.get_child_count()
		if c > 0:
			var item = slot.get_child(0)
			if item is Weapon:
				if item.weapon_attributes:
					
					slot.tooltip_text = item.weapon_attributes.as_text()

@onready var weapon_slot : Slot = $Prepare/Inventory/WeaponSlot
@onready var head_slot : Slot = $Prepare/Inventory/HeadSlot
@onready var chest_slot : Slot = $Prepare/Inventory/ChestSlot
@onready var legs_slot : Slot = $Prepare/Inventory/LegsSlot
@onready var accessory1_slot : Slot = $Prepare/Inventory/Acc1Slot
@onready var accessory2_slot : Slot = $Prepare/Inventory/Acc2Slot

func _on_head_slot_gui_input(event: InputEvent) -> void:
	item_selected(event, head_slot)

func _on_chest_slot_gui_input(event: InputEvent) -> void:
	item_selected(event, chest_slot)
	
func _on_legs_slot_gui_input(event: InputEvent) -> void:
	item_selected(event, legs_slot)

func _on_acc_1_slot_gui_input(event: InputEvent) -> void:
	item_selected(event, accessory1_slot)

func _on_acc_2_slot_gui_input(event: InputEvent) -> void:
	item_selected(event, accessory2_slot)

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
			new_weapon.weapon_attributes = item.weapon_attributes
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
		node.queue_free()
	for child in weapon_slot.get_children():
		child.queue_free()
	if inventory_selected_character:
		var sprite = inventory_selected_character.get_node("Mirror").duplicate()
		var weapon_node = inventory_selected_character.get_node("Mirror/Weapon")
		if weapon_node.get_child_count() > 0:
			var weapon = weapon_node.get_child(0).duplicate()
			weapon.weapon_attributes = weapon_node.get_child(0).weapon_attributes
			weapon_slot.add_child(weapon)
			weapon.scale = Vector2.ONE * 2
			weapon.position = slot_offset
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
