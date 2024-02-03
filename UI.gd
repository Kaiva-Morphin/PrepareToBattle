extends Control


var inventory_opened = false
var cell_texture = load("res://src/sprites/UI/InventoryCell.png")
var character = preload("res://src/Entities/Man.tscn")



@onready var squad_selector = $Prepare/Selector
@onready var squad_selector_frame_container = $Prepare/Selector/ScrollContainer/HBoxContainer

var space_state : PhysicsDirectSpaceState2D = null
func _physics_process(_delta: float) -> void:
	space_state = get_world_2d().direct_space_state

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
	if Input.is_action_just_released("lmb"):
		if picked_node:
			picked_node.collision.disabled = false
			var rect = squad_selector.get_global_rect()
			if rect.has_point(get_global_mouse_position()):
				picked_node.collision.disabled = true
				add_to_bar(picked_node)
			$Prepare/Selector/Hint.hide()
			picked_node = null
	if picked_node:
		picked_node.position = pos

func add_to_bar(e: Entity):
	var rect = TextureRect.new()
	rect.texture = cell_texture
	rect.custom_minimum_size = Vector2(64, 64)
	rect.name = str(e.get_instance_id())
	rect.connect("gui_input", func(event): _bar_cell_gui_input(event, get_path_to(rect)) )
	squad_selector_frame_container.add_child(rect)
	picked_node.scale = Vector2.ONE * 2
	e.reparent(rect)
	e.position = rect.custom_minimum_size / 2

func _bar_cell_gui_input(event: InputEvent, path) -> void: # for picking, not drop
	if is_inventory_open: # select
		if event is InputEventMouseButton:
			if event.pressed:
				var node = get_node_or_null(path)
				if node:
					var v = node.get_child_count()
					if v > 0:
						inventory_selected_character = node.get_child(0)
						update_inventory_character_preview()
	else: # check for put
		if event is InputEventScreenDrag:
				var rect = squad_selector.get_global_rect()
				rect.position -= Vector2(2, 2)
				rect.size += Vector2(2, 2) 
				if rect.has_point(get_global_mouse_position()):
					pass
				else: # put
					var node = get_node_or_null(path)
					if node:
						var v = node.get_child_count()
						if v > 0:
							$Prepare/Selector/Hint.show()
							var child = node.get_child(0)
							picked_node = child
							picked_node.scale = Vector2.ONE
							picked_node.reparent(Game.manager)
							node.queue_free()


var inventory_selected_character : Entity = null

var is_inventory_open = false
func _ready():
	is_inventory_open = $Prepare/Inventory.visible
	add_item(Weapons.FireWard.instantiate().duplicate())
	add_item(Weapons.Fists.instantiate().duplicate())
	add_item(Weapons.FireWard.instantiate().duplicate())


func _on_inventory_button_pressed() -> void:
	is_inventory_open = !is_inventory_open
	if is_inventory_open:
		$Prepare/InventoryButton.texture_normal.region.position = Vector2(32, 0)
		$Prepare/InventoryButton.texture_pressed.region.position = Vector2(48, 0)
		inventory_selected_character = null
		update_inventory_character_preview()
		$Prepare/Inventory.show()
	else:
		$Prepare/InventoryButton.texture_normal.region.position = Vector2(0, 0)
		$Prepare/InventoryButton.texture_pressed.region.position = Vector2(16, 0)
		$Prepare/Inventory.hide()

@onready var weapon_slot = $Prepare/Inventory/WeaponSlot
@onready var inventory_container = $Prepare/Inventory/ScrollContainer/GridContainer

var slot_offset = Vector2(24, 24)

func update_inventory_character_preview():
	var preview_node = $Prepare/Inventory/Preview
	$Prepare/Inventory/Hint.hide()
	for node in preview_node.get_children():
		node.queue_free()
	if inventory_selected_character:
		var sprite = inventory_selected_character.get_node("Mirror").duplicate()
		var weapon = inventory_selected_character.get_node("Mirror/Weapon").duplicate()
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


var selected_slot : Panel = null

func item_selected(event: InputEvent, slot: Panel):
	pass

func swap_slots():
	pass

func highlight_slot():
	pass

func add_item(item: Item):
	var slot = $Prepare/Inventory/ScrollContainer/Slot_Template.duplicate()
	slot.show()
	item.scale = Vector2.ONE * 2
	if item.get_parent():
		item.reparent(slot)
	else:
		slot.add_child(item)
	item.position = slot_offset
	inventory_container.add_child(slot)
	slot.connect("gui_input", func(event): item_selected(event, slot))


func _on_head_slot_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
